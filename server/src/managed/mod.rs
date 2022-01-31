use crate::managed::logs::ManagedLogs;
use rocket::fairing::AdHoc;
use rocket::http::Status;
use rocket::serde::json::Json;

pub(crate) mod logs;

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

pub fn ignite() -> AdHoc {
    AdHoc::on_ignite("commands", |rocket| async move {
        rocket.mount("/api/managed", routes![log_files, log_file])
    })
}
