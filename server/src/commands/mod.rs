mod logs;
mod status;
mod update;

use crate::commands::logs::OutputLogLine;
use crate::commands::status::ServerStatus;
use crate::commands::update::UpdateOptions;
use crate::managed::logs::ManagedLogs;
use rocket::fairing::AdHoc;
use rocket::http::Status;
use rocket::response::stream::{Event, EventStream};
use rocket::serde::json::Json;

#[get("/status")]
pub fn execute_status() -> Json<ServerStatus> {
    Json(ServerStatus::execute())
}

#[get("/tail?<log>")]
pub async fn tail_log(log: String) -> Result<EventStream![], Status> {
    match ManagedLogs::new().to_lines(log).await {
        Ok(mut lines) => Ok(EventStream! {
            loop {
                if let Ok(Some(line)) = lines.next_line().await {
                    yield Event::json(&OutputLogLine::from(line));
                }
            }
        }),
        Err(status) => Err(status),
    }
}

#[post("/start")]
pub async fn start_command() -> Status {
    crate::utils::unix_socket::send_command(
        agent::AgentCommand::from(agent::Command::Start).to_string(),
    )
    .unwrap();
    Status::Ok
}

#[post("/stop")]
pub async fn stop_command() -> Status {
    crate::utils::unix_socket::send_command(
        agent::AgentCommand::from(agent::Command::Stop).to_string(),
    )
    .unwrap();
    Status::Ok
}

#[post("/restart")]
pub async fn restart_command() -> Status {
    crate::utils::unix_socket::send_command(
        agent::AgentCommand::from(agent::Command::Restart).to_string(),
    )
    .unwrap();
    Status::Ok
}

#[post("/update", data = "<options>")]
pub async fn update_command(options: Json<UpdateOptions>) -> Status {
    let mut command = agent::AgentCommand::from(agent::Command::Update);
    command.command_arguments = options.into_inner().to_vec();
    crate::utils::unix_socket::send_command(command.to_string()).unwrap();
    Status::Ok
}

pub fn ignite() -> AdHoc {
    AdHoc::on_ignite("commands", |rocket| async move {
        rocket.mount(
            "/api/command",
            routes![
                execute_status,
                tail_log,
                start_command,
                stop_command,
                restart_command,
                update_command
            ],
        )
    })
}
