use crate::utils::{is_ark_installed, strip_ansi};
use serde::{Deserialize, Serialize};
use std::env;
use std::fs::read_to_string;
use std::path::{Path, PathBuf};
use std::process::Command;

#[derive(Serialize, Deserialize)]
pub struct ServerStatus {
    instance: String,
    running: bool,
    listening: bool,
    online: bool,
    installed: bool,
    build_id: String,
    version: String,
    ark_servers_link: String,
    steam_connect: String,
}

fn install_path() -> PathBuf {
    env::var("INSTALL_PATH")
        .map(PathBuf::from)
        .or_else(|_| {
            env::var("ARK_DIRECTORY")
                .map(PathBuf::from)
                .or_else(|_| env::var("HOME").map(|home| PathBuf::from(format!("{home}/ARK"))))
        })
        .unwrap_or_else(|_| PathBuf::from("/home/steam/ARK"))
}

fn process_running(pid: u32) -> bool {
    Path::new(&format!("/proc/{pid}")).exists()
}

fn is_running_from_pid_file() -> bool {
    let pid_file = install_path().join("instance.pid");
    match read_to_string(pid_file) {
        Ok(content) => match content.trim().parse::<u32>() {
            Ok(pid) => process_running(pid),
            Err(_) => false,
        },
        Err(_) => false,
    }
}

fn manifest_build_id() -> String {
    let app_id = env::var("APP_ID").unwrap_or_else(|_| String::from("376030"));
    let app_manifest = install_path()
        .join("steamapps")
        .join(format!("appmanifest_{app_id}.acf"));
    match read_to_string(app_manifest) {
        Ok(contents) => match regex::Regex::new(r#""buildid"\s*"([0-9]+)""#) {
            Ok(regexp) => regexp
                .captures(&contents)
                .and_then(|captures| captures.get(1).map(|value| String::from(value.as_str())))
                .unwrap_or_default(),
            Err(_) => String::new(),
        },
        Err(_) => String::new(),
    }
}

fn status_version() -> String {
    let output = Command::new("gsm-cli").arg("--version").output();
    match output {
        Ok(res) => match String::from_utf8(res.stdout) {
            Ok(stdout) => strip_ansi(stdout.trim()),
            Err(_) => String::new(),
        },
        Err(_) => String::new(),
    }
}

fn default_steam_connect() -> String {
    match env::var("EXTERNAL_ADDRESS") {
        Ok(address) => {
            let port = env::var("EXTERNAL_PORT")
                .or_else(|_| env::var("QUERY_PORT"))
                .unwrap_or_else(|_| String::from("27015"));
            format!("steam://connect/{address}:{port}")
        }
        Err(_) => String::new(),
    }
}

impl ServerStatus {
    pub fn execute() -> ServerStatus {
        let running = is_running_from_pid_file();
        let build_id = manifest_build_id();
        let version = status_version();
        ServerStatus {
            instance: env::var("NAME").unwrap_or_else(|_| String::from("ARK Server")),
            running,
            listening: running,
            online: running,
            installed: is_ark_installed(),
            ark_servers_link: env::var("ARK_SERVERS_LINK").unwrap_or_default(),
            steam_connect: env::var("STEAM_CONNECT").unwrap_or_else(|_| default_steam_connect()),
            build_id: build_id.clone(),
            version: if version.is_empty() {
                build_id
            } else {
                version
            },
        }
    }
}
