use rocket::http::Status;
use shared::constants::CONFIGS;
use shared::utils::{ark_manager_config_dir, game_dir};
use std::fs::{read, write};
use std::path::Path;
use std::string::FromUtf8Error;

pub struct ManagedConfig {
    file_path: String,
}

pub fn config_files() -> Vec<String> {
    CONFIGS
        .iter()
        .map(|e| {
            e.replace("<ARK_DIR>", game_dir().unwrap().as_str())
                .replace(
                    "<ARK_MANAGER_CONFIG_DIR>",
                    ark_manager_config_dir().unwrap().as_str(),
                )
        })
        .collect::<Vec<String>>()
}

impl ManagedConfig {
    pub fn open(file_path: String) -> Result<ManagedConfig, Status> {
        if config_files().contains(&file_path) {
            if Path::new(&file_path).exists() {
                Ok(ManagedConfig { file_path })
            } else {
                Err(Status::NotFound)
            }
        } else {
            Err(Status::Unauthorized)
        }
    }
    pub fn write(&self, content: String) -> std::io::Result<()> {
        write(Path::new(&self.file_path), content)
    }
    pub fn read(&self) -> Result<String, FromUtf8Error> {
        String::from_utf8(read(Path::new(&self.file_path)).unwrap())
    }
}
