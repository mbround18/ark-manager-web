#![feature(async_stream)]

//noinspection RsMainFunctionNotFound
mod commands;
mod managed;
mod utils;

#[macro_use]
extern crate rocket;

use rocket::http::Status;

const NOT_FOUND_INDEX: &str = "<html><body><h1>No Index Found</h1></body></html>";

#[get("/healthcheck")]
fn index() -> Status {
    Status::Ok
}

#[launch]
fn rocket() -> _ {
    use rocket::fs::FileServer;
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
    rocket::build()
        .mount("/", FileServer::from(public_path))
        .mount("/api", routes![index])
        .attach(commands::ignite())
        .attach(managed::ignite())
}
