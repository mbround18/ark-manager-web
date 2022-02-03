use crate::command::Command;
use crate::errors::failed_to_parse::FailedToParseCommand;
use serde::{Deserialize, Serialize};
use std::str::FromStr;

#[derive(Serialize, Deserialize)]
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
    pub fn command_type(&self) -> Result<Command, FailedToParseCommand> {
        Command::from_str(&self.namespace)
    }
}
