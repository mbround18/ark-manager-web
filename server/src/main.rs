//noinspection RsMainFunctionNotFound
mod commands;
mod managed;
mod utils;

use actix_files::Files;
use actix_web::{web, App, HttpResponse, HttpServer};

const NOT_FOUND_INDEX: &str = "<html><body><h1>No Index Found</h1></body></html>";

async fn heartbeat() -> HttpResponse {
    HttpResponse::Ok().finish()
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    use std::{
        env,
        fs::{create_dir_all, write},
        path::Path,
    };

    let current_dir = env::current_dir().unwrap();
    let path = current_dir.join("dist");
    let public_path =
        env::var("PUBLIC_PATH").unwrap_or_else(|_| path.to_str().unwrap().to_string());
    let index_path = Path::new(&public_path).join("index.html");
    if !index_path.exists() {
        match create_dir_all(&public_path) {
            Ok(_) => write(index_path, NOT_FOUND_INDEX).unwrap(),
            Err(_) => panic!("Failed to create {}", public_path),
        }
    }

    let bind_address = env::var("SERVER_ADDRESS")
        .or_else(|_| env::var("ROCKET_ADDRESS"))
        .unwrap_or_else(|_| String::from("127.0.0.1"));
    let bind_port = env::var("SERVER_PORT")
        .or_else(|_| env::var("ROCKET_PORT"))
        .ok()
        .and_then(|value| value.parse::<u16>().ok())
        .unwrap_or(8000);

    HttpServer::new(move || {
        App::new()
            .route("/heartbeat", web::get().to(heartbeat))
            .route("/api/heartbeat", web::get().to(heartbeat))
            .configure(commands::configure)
            .configure(managed::configure)
            .service(Files::new("/", public_path.clone()).index_file("index.html"))
    })
    .bind((bind_address, bind_port))?
    .run()
    .await
}

#[cfg(test)]
mod tests {
    use super::*;
    use actix_web::{http::StatusCode, test, App};

    #[actix_web::test]
    async fn heartbeat_routes_return_ok() {
        let app = test::init_service(
            App::new()
                .route("/heartbeat", web::get().to(heartbeat))
                .route("/api/heartbeat", web::get().to(heartbeat))
                .configure(commands::configure)
                .configure(managed::configure),
        )
        .await;

        let req = test::TestRequest::get().uri("/heartbeat").to_request();
        let resp = test::call_service(&app, req).await;
        assert_eq!(resp.status(), StatusCode::OK);

        let req = test::TestRequest::get().uri("/api/heartbeat").to_request();
        let resp = test::call_service(&app, req).await;
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[actix_web::test]
    async fn managed_log_rejects_unapproved_paths() {
        let app = test::init_service(App::new().configure(managed::configure)).await;

        let req = test::TestRequest::get()
            .uri("/api/managed/log?path=/tmp/not-allowed.log")
            .to_request();
        let resp = test::call_service(&app, req).await;
        assert_eq!(resp.status(), StatusCode::UNAUTHORIZED);
    }

    #[actix_web::test]
    async fn tail_log_rejects_unapproved_paths() {
        let app = test::init_service(App::new().configure(commands::configure)).await;

        let req = test::TestRequest::get()
            .uri("/api/command/tail?log=/tmp/not-allowed.log")
            .to_request();
        let resp = test::call_service(&app, req).await;
        assert_eq!(resp.status(), StatusCode::UNAUTHORIZED);
    }

    #[actix_web::test]
    async fn read_config_returns_bad_request_without_path_query() {
        let app = test::init_service(App::new().configure(managed::configure)).await;

        let req = test::TestRequest::get()
            .uri("/api/managed/config")
            .to_request();
        let resp = test::call_service(&app, req).await;
        assert_eq!(resp.status(), StatusCode::BAD_REQUEST);
    }
}
