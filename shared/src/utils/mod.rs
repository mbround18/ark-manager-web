use std::env;
use std::env::VarError;

pub fn ark_manager_config_dir() -> Result<String, VarError> {
    match env::var("ARK_MANAGER_CONFIG_DIRECTORY") {
        Ok(v) => Ok(v),
        Err(_) => match env::var("HOME") {
            Ok(home) => Ok(format!("{}/.config/arkmanager", home)),
            Err(e) => Err(e),
        },
    }
}

pub fn game_dir() -> Result<String, VarError> {
    match env::var("ARK_DIRECTORY") {
        Ok(v) => Ok(v),
        Err(_) => match env::var("HOME") {
            Ok(home) => Ok(format!("{}/ARK", home)),
            Err(e) => Err(e),
        },
    }
}
