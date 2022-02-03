use crate::errors::failed_to_parse::FailedToParseCommand;
use std::str::FromStr;

pub enum Command {
    Start,
    Stop,
    Restart,
    Update,
    Status,
    Install,
}

impl ToString for Command {
    fn to_string(&self) -> String {
        use Command::{Install, Restart, Start, Status, Stop, Update};
        String::from(match self {
            Start => "ArkManager::Start",
            Stop => "ArkManager::Stop",
            Restart => "ArkManager::Restart",
            Update => "ArkManager::Update",
            Status => "ArkManager::Status",
            Install => "ArkManager::Install",
        })
    }
}

impl FromStr for Command {
    type Err = FailedToParseCommand;
    fn from_str(s: &str) -> Result<Command, FailedToParseCommand> {
        match s {
            "ArkManager::Start" => Ok(Command::Start),
            "ArkManager::Stop" => Ok(Command::Stop),
            "ArkManager::Update" => Ok(Command::Update),
            "ArkManager::Restart" => Ok(Command::Restart),
            "ArkManager::Status" => Ok(Command::Status),
            "ArkManager::Install" => Ok(Command::Install),
            _ => Err(FailedToParseCommand),
        }
    }
}
