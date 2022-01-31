pub mod ark_manager_path;
pub mod constants;
pub mod logger;
pub mod macros;
mod state;

pub use state::StateStorage;
use std::str::FromStr;

pub enum Command {
    Start,
    Stop,
    Restart,
    Update,
    Status,
}

impl ToString for Command {
    fn to_string(&self) -> String {
        use Command::{Restart, Start, Status, Stop, Update};
        String::from(match self {
            Start => "ArkManager::Start",
            Stop => "ArkManager::Stop",
            Restart => "ArkManager::Restart",
            Update => "ArkManager::Update",
            Status => "ArkManager::Status",
        })
    }
}

impl FromStr for Command {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "ArkManager::Start" => Ok(Command::Start),
            "ArkManager::Stop" => Ok(Command::Stop),
            "ArkManager::Update" => Ok(Command::Update),
            "ArkManager::Restart" => Ok(Command::Restart),
            "ArkManager::Status" => Ok(Command::Status),
            _ => Err(()),
        }
    }
}

#[derive(serde::Serialize, serde::Deserialize)]
pub struct AgentCommand {
    namespace: String,
    pub command_arguments: Option<Vec<String>>,
}

impl ToString for AgentCommand {
    fn to_string(&self) -> String {
        serde_json::to_string(self).unwrap()
    }
}

impl From<Command> for AgentCommand {
    fn from(cmd: Command) -> Self {
        AgentCommand {
            namespace: cmd.to_string(),
            command_arguments: None,
        }
    }
}

impl AgentCommand {
    #[allow(dead_code)]
    pub fn command_type(&self) -> Result<Command, ()> {
        Command::from_str(&self.namespace)
    }
}
