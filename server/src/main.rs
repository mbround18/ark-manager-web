#[macro_use]
extern crate rocket;
use std::env;
use rocket::fs::FileServer;

#[get("/hello")]
fn index() -> &'static str {
    "Hello, world!"
}

#[launch]
fn rocket() -> _ {
    let current_dir = env::current_dir().unwrap();
    let path = current_dir.join("dist");
    let public_path = env::var("PUBLIC_PATH").unwrap_or(path.to_str().unwrap().to_string());

    rocket::build()
        .mount("/", FileServer::from(public_path))
        .mount("/api", routes![index])
}
