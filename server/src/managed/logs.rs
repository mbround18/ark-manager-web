use actix_web::http::StatusCode;
use linemux::MuxedLines;
use std::env;
use std::fs::read;
use std::path::Path;

const DEFAULT_LOG: &str = "/tmp/ark-manager-web/out.log";
const DEFAULT_INSTALL_PATH: &str = "/home/steam/ARK";

#[derive(serde::Serialize)]
pub struct ManagedLogs {
    log_files: Box<[String]>,
}

fn add_shooter_game_log(logs: &mut Vec<String>) {
    if let Ok(home) = env::var("HOME") {
        let shooter_game_log = Path::new(&home).join("ARK/ShooterGame/Saved/Logs/ShooterGame.log");
        if shooter_game_log.exists() {
            logs.push(String::from(shooter_game_log.to_str().unwrap()))
        }
    }
}

fn add_gsm_logs(logs: &mut Vec<String>) {
    let install_path =
        env::var("INSTALL_PATH").unwrap_or_else(|_| String::from(DEFAULT_INSTALL_PATH));
    let server_log = Path::new(&install_path).join("logs/server.log");
    if server_log.exists() {
        logs.push(String::from(server_log.to_str().unwrap()));
    }
    let server_err_log = Path::new(&install_path).join("logs/server.err");
    if server_err_log.exists() {
        logs.push(String::from(server_err_log.to_str().unwrap()));
    }
}

impl Default for ManagedLogs {
    fn default() -> Self {
        let mut logs = vec![String::from(DEFAULT_LOG)];
        add_shooter_game_log(&mut logs);
        add_gsm_logs(&mut logs);
        ManagedLogs {
            log_files: Box::from(logs),
        }
    }
}

impl ManagedLogs {
    pub fn new() -> ManagedLogs {
        match env::var("MANAGED_LOG_FILES") {
            Ok(files) => {
                let log_files: Box<[String]> = files
                    .split(',')
                    .map(String::from)
                    .collect::<Vec<String>>()
                    .into_boxed_slice();
                ManagedLogs { log_files }
            }
            Err(_) => ManagedLogs::default(),
        }
    }
    pub async fn read(&self, log_file: String) -> Result<Vec<String>, StatusCode> {
        if self.log_files.contains(&log_file) {
            return match read(log_file) {
                Ok(file) => match String::from_utf8(file) {
                    Ok(content) => Ok(content
                        .split('\n')
                        .map(String::from)
                        .collect::<Vec<String>>()),
                    Err(_) => Err(StatusCode::UNPROCESSABLE_ENTITY),
                },
                Err(_) => Err(StatusCode::UNPROCESSABLE_ENTITY),
            };
        }
        Err(StatusCode::UNAUTHORIZED)
    }
    pub async fn to_lines(&self, log_file: String) -> Result<MuxedLines, StatusCode> {
        if self.log_files.contains(&log_file) {
            let mut lines = MuxedLines::new().map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

            // Register some files to be tailed, whether they currently exist or not.
            // Hypothetically, this can be expanded to multiple logs.
            lines
                .add_file(log_file)
                .await
                .map_err(|_| StatusCode::UNPROCESSABLE_ENTITY)?;

            Ok(lines)
        } else {
            Err(StatusCode::UNAUTHORIZED)
        }
    }
}
