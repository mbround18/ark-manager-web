use crate::managed::configs::{config_files, ManagedConfig};
use crate::managed::logs::ManagedLogs;
use actix_web::{http::StatusCode, web, HttpResponse};
use shared::{log, StateStorage};

pub(crate) mod configs;
pub(crate) mod logs;

#[derive(serde::Deserialize)]
struct PathQuery {
    path: String,
}

pub fn configure(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/managed")
            .route("/state", web::get().to(get_state))
            .route("/logs", web::get().to(log_files))
            .route("/log", web::get().to(log_file))
            .route("/configs", web::get().to(get_configs))
            .route("/config", web::get().to(read_config))
            .route("/config", web::post().to(write_config)),
    );
}

async fn get_state() -> web::Json<StateStorage> {
    web::Json(StateStorage::read())
}

async fn log_files() -> web::Json<ManagedLogs> {
    web::Json(ManagedLogs::new())
}

async fn log_file(query: web::Query<PathQuery>) -> HttpResponse {
    match ManagedLogs::new().read(query.path.clone()).await {
        Ok(res) => HttpResponse::Ok().json(res),
        Err(status) => HttpResponse::build(status).finish(),
    }
}

async fn get_configs() -> web::Json<Vec<String>> {
    web::Json(config_files())
}

async fn read_config(query: web::Query<PathQuery>) -> HttpResponse {
    let decoded_path = match urlencoding::decode(&query.path) {
        Ok(value) => value.to_string(),
        Err(_) => return HttpResponse::BadRequest().finish(),
    };

    match ManagedConfig::open(decoded_path) {
        Ok(config) => match config.read() {
            Ok(contents) => HttpResponse::Ok().body(contents),
            Err(_) => HttpResponse::UnprocessableEntity().finish(),
        },
        Err(status) => HttpResponse::build(status).finish(),
    }
}

async fn write_config(query: web::Query<PathQuery>, content: String) -> HttpResponse {
    let decoded_path = match urlencoding::decode(&query.path) {
        Ok(value) => value.to_string(),
        Err(_) => return HttpResponse::BadRequest().finish(),
    };

    match ManagedConfig::open(decoded_path.clone()) {
        Ok(config) => match config.write(content) {
            Ok(_) => HttpResponse::Ok().finish(),
            Err(error) => {
                log(
                    String::from("ArkManager::FileService"),
                    format!("Failed to write {} with {}", decoded_path, error),
                );
                HttpResponse::build(StatusCode::UNPROCESSABLE_ENTITY).finish()
            }
        },
        Err(status) => HttpResponse::build(status).finish(),
    }
}
