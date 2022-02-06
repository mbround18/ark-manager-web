use crate::managed::configs::{config_files, ManagedConfig};
use crate::managed::logs::ManagedLogs;
use rocket::fairing::AdHoc;
use rocket::http::Status;
use rocket::serde::json::Json;
use shared::{log, StateStorage};

pub(crate) mod configs;
pub(crate) mod logs;

#[get("/state")]
pub async fn get_state() -> Json<StateStorage> {
    Json(StateStorage::read())
}

#[get("/logs")]
pub async fn log_files() -> Json<ManagedLogs> {
    Json(ManagedLogs::new())
}

#[get("/log?<path>")]
pub async fn log_file(path: String) -> Result<Json<Vec<String>>, Status> {
    match ManagedLogs::new().read(path).await {
        Ok(res) => Ok(Json(res)),
        Err(e) => Err(e),
    }
}

#[get("/configs")]
pub fn get_configs() -> Json<Vec<String>> {
    Json(config_files())
}

#[get("/config?<path>")]
pub async fn read_config(path: String) -> Result<String, Status> {
    let decoded_path = urlencoding::decode(&path).unwrap().to_string();
    match ManagedConfig::open(decoded_path) {
        Ok(config) => Ok(config.read().unwrap()),
        Err(e) => Err(e),
    }
}

#[post("/config?<path>", data = "<content>")]
pub async fn write_config(path: String, content: String) -> Result<Status, Status> {
    let decoded_path = urlencoding::decode(&path).unwrap().to_string();
    match ManagedConfig::open(decoded_path.clone()) {
        Ok(config) => match config.write(content) {
            Ok(_) => Ok(Status::Ok),
            Err(e) => {
                log(
                    String::from("ArkManager::FileService"),
                    format!("Failed to write {} with {}", decoded_path, e),
                );
                Err(Status::UnprocessableEntity)
            }
        },
        Err(e) => Err(e),
    }
}

pub fn ignite() -> AdHoc {
    AdHoc::on_ignite("commands", |rocket| async move {
        rocket.mount(
            "/api/managed",
            routes![
                log_files,
                log_file,
                get_state,
                get_configs,
                write_config,
                read_config
            ],
        )
    })
}
