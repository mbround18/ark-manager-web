mod logs;
mod status;
mod update;

use crate::commands::logs::OutputLogLine;
use crate::commands::status::ServerStatus;
use crate::commands::update::UpdateOptions;
use crate::managed::logs::ManagedLogs;
use actix_web::{web, HttpResponse};
use shared::{log, AgentCommand, Command};

#[derive(serde::Deserialize)]
struct TailQuery {
    log: String,
}

pub fn configure(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/command")
            .route("/status", web::get().to(execute_status))
            .route("/tail", web::get().to(tail_log))
            .route("/start", web::post().to(start_command))
            .route("/stop", web::post().to(stop_command))
            .route("/restart", web::post().to(restart_command))
            .route("/install", web::post().to(install_command))
            .route("/update", web::post().to(update_command)),
    );
}

async fn execute_status() -> web::Json<ServerStatus> {
    web::Json(ServerStatus::execute())
}

async fn tail_log(query: web::Query<TailQuery>) -> HttpResponse {
    let mut lines = match ManagedLogs::new().to_lines(query.log.clone()).await {
        Ok(lines) => lines,
        Err(status) => return HttpResponse::build(status).finish(),
    };

    let stream = async_stream::stream! {
        loop {
            match lines.next_line().await {
                Ok(Some(line)) => {
                    let payload = serde_json::to_string(&OutputLogLine::from(line)).unwrap();
                    let sse = format!("data: {payload}\n\n");
                    yield Ok::<_, actix_web::Error>(web::Bytes::from(sse));
                }
                Ok(None) => break,
                Err(_) => break,
            }
        }
    };

    HttpResponse::Ok()
        .insert_header(("Content-Type", "text/event-stream"))
        .insert_header(("Cache-Control", "no-cache"))
        .streaming(stream)
}

fn send_agent_command(command: Command) -> HttpResponse {
    let agent_command = AgentCommand::from(command).to_string();
    match crate::utils::unix_socket::send_command(agent_command) {
        Ok(_) => HttpResponse::Ok().finish(),
        Err(error) => {
            log(
                String::from("ArkManager::CommandService"),
                format!("Failed to send command: {error}"),
            );
            HttpResponse::InternalServerError().finish()
        }
    }
}

async fn start_command() -> HttpResponse {
    send_agent_command(Command::Start)
}

async fn stop_command() -> HttpResponse {
    send_agent_command(Command::Stop)
}

async fn restart_command() -> HttpResponse {
    send_agent_command(Command::Restart)
}

async fn install_command() -> HttpResponse {
    send_agent_command(Command::Install)
}

async fn update_command(options: web::Json<UpdateOptions>) -> HttpResponse {
    let mut command = AgentCommand::from(Command::Update);
    command.command_arguments = options.into_inner().to_vec();

    match crate::utils::unix_socket::send_command(command.to_string()) {
        Ok(_) => HttpResponse::Ok().finish(),
        Err(error) => {
            log(
                String::from("ArkManager::CommandService"),
                format!("Failed to send update command: {error}"),
            );
            HttpResponse::InternalServerError().finish()
        }
    }
}
