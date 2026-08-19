use actix_web::http::StatusCode;
use shared::constants::CONFIGS;
use shared::utils::{ark_manager_config_dir, game_dir};
use std::fs::{read, write};
use std::path::Path;

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
    pub fn open(file_path: String) -> Result<ManagedConfig, StatusCode> {
        if config_files().contains(&file_path) {
            if Path::new(&file_path).exists() {
                Ok(ManagedConfig { file_path })
            } else {
                Err(StatusCode::NOT_FOUND)
            }
        } else {
            Err(StatusCode::UNAUTHORIZED)
        }
    }
    pub fn write(&self, content: String) -> std::io::Result<()> {
        write(Path::new(&self.file_path), content)
    }
    pub fn read(&self) -> std::io::Result<String> {
        let bytes = read(Path::new(&self.file_path))?;
        String::from_utf8(bytes).map_err(|_| std::io::Error::from(std::io::ErrorKind::InvalidData))
    }
}
