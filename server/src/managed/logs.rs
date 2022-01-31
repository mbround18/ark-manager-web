use linemux::MuxedLines;
use rocket::http::Status;
use std::env;
use std::fs::read;
use std::path::Path;

const DEFAULT_LOG: &'static str = "/tmp/ark-manager-web/out.log";

#[derive(serde::Serialize)]
pub struct ManagedLogs {
    log_files: Box<[String]>,
}

fn add_shooter_game_log(logs: &mut Vec<String>) {
    match env::var("HOME") {
        Ok(home) => {
            let shooter_game_log =
                Path::new(&home).join("ARK/ShooterGame/Saved/Logs/ShooterGame.log");
            if shooter_game_log.exists() {
                logs.push(String::from(shooter_game_log.to_str().unwrap()))
            }
        }
        _ => {}
    }
}

impl Default for ManagedLogs {
    fn default() -> Self {
        let mut logs = vec![String::from(DEFAULT_LOG)];
        add_shooter_game_log(&mut logs);
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
    pub async fn read(&self, log_file: String) -> Result<Vec<String>, Status> {
        if self.log_files.contains(&log_file) {
            return match read(log_file) {
                Ok(file) => Ok(String::from_utf8(file)
                    .unwrap()
                    .split("\n")
                    .map(String::from)
                    .collect::<Vec<String>>()),
                Err(_) => Err(Status::UnprocessableEntity),
            };
        }
        Err(Status::Unauthorized)
    }
    pub async fn to_lines(&self, log_file: String) -> Result<MuxedLines, Status> {
        if self.log_files.contains(&log_file) {
            let mut lines = MuxedLines::new().unwrap();

            // Register some files to be tailed, whether they currently exist or not.
            // Hypothetically, this can be expanded to multiple logs.
            lines.add_file(log_file).await.unwrap();

            Ok(lines)
        } else {
            Err(Status::Unauthorized)
        }
    }
}
