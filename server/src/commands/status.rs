use regex::{Captures, Regex};
use rocket::form::validate::Contains;
use std::convert::From;
use std::env;
use std::process::Command;
use std::str::Lines;

const INSTANCE_NAME_REGEX: &str = r#"'([a-zA-Z0-9_]*)'$"#;

use crate::utils::{is_ark_installed, strip_ansi};
use serde::{Deserialize, Serialize};
use shared::ark_manager_path;

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

fn check_nd_replace_external(link: String) -> String {
    let reg = r#"^(.*/(connect|server))/(.*):(27015)$"#;
    if let Ok(external_address) = env::var("EXTERNAL_ADDRESS") {
        let rex = Regex::new(reg).unwrap();
        rex.replace(&link, |caps: &Captures| {
            let port = if let Ok(external_port) = env::var("EXTERNAL_PORT") {
                external_port
            } else {
                String::from(&caps[4])
            };
            format!("{}/{}:{}", &caps[1], external_address, port)
        }).to_string()
    } else {
        link
    }
}

impl From<String> for ServerStatus {
    fn from(status: String) -> Self {
        let mut lines = status.lines();
        ServerStatus {
            instance: ServerStatus::instance_from_str(lines.next().unwrap()),
            running: ServerStatus::parse_yes_no(&mut lines, "running"),
            listening: ServerStatus::parse_yes_no(&mut lines, "listening"),
            online: ServerStatus::parse_yes_no(&mut lines, "online"),
            installed: is_ark_installed(),
            ark_servers_link: check_nd_replace_external(
                ServerStatus::parse_value(&mut lines, "ARKServers")
            ),
            steam_connect: check_nd_replace_external(
                ServerStatus::parse_value(&mut lines, "connect link")
            ),
            build_id: ServerStatus::parse_value(&mut lines, "build ID"),
            version: ServerStatus::parse_value(&mut lines, "version"),
        }
    }
}

impl ToString for ServerStatus {
    fn to_string(&self) -> String {
        serde_json::to_string(&self).unwrap()
    }
}

impl ServerStatus {
    fn parse_yes_no(lines: &mut Lines, pattern: &str) -> bool {
        if let Some(line) = lines.find(|e| e.contains(pattern)) {
            line.contains("Yes")
        } else {
            false
        }
    }
    fn parse_value(lines: &mut Lines, pattern: &str) -> String {
        if let Some(line) = lines.find(|e| e.contains(pattern)) {
            let first_pos = line.chars().position(|e| e.eq(&':')).unwrap();
            let rest_of_string = &line[(first_pos + 1)..];
            String::from(rest_of_string.trim())
        } else {
            String::from("")
        }
    }
    fn instance_from_str(data: &str) -> String {
        let instance_regex = Regex::new(INSTANCE_NAME_REGEX).unwrap();
        let instance_captures = instance_regex.captures(data);
        if let Some(captures) = instance_captures {
            String::from(captures.get(1).map_or("", |m| m.as_str()))
        } else {
            String::from("unknown")
        }
    }
    pub fn execute() -> ServerStatus {
        let command = Command::new(ark_manager_path())
            .args(["status"])
            .output()
            .expect("failed to execute process");
        let output = String::from_utf8(command.stdout).unwrap();
        ServerStatus::from(strip_ansi(&output))
    }
}
