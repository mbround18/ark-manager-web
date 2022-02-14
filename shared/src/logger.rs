use crate::DEFAULT_LOG;
use serde::Serialize;
use std::fs::OpenOptions;
use std::io::prelude::*;

#[derive(Serialize)]
pub struct LogMessage {
    namespace: String,
    timestamp: String,
    content: String,
}

impl LogMessage {
    pub fn new(namespace: String, content: String) -> LogMessage {
        LogMessage {
            namespace,
            content,
            timestamp: chrono::Local::now().to_string(),
        }
    }
}

pub fn log(namespace: String, message: String) {
    let content = String::from_utf8(strip_ansi_escapes::strip(message).unwrap()).unwrap();
    let mut file = OpenOptions::new()
        .write(true)
        .append(true)
        .open(DEFAULT_LOG)
        .unwrap();

    if let Err(e) = writeln!(
        file,
        "{}",
        serde_json::to_string(&LogMessage::new(namespace, content)).unwrap()
    ) {
        eprintln!("Couldn't write to file: {}", e);
    }
}

#[allow(dead_code)]
pub fn agent_log(message: String) {
    log(String::from("ArkManager::Agent"), message)
}
