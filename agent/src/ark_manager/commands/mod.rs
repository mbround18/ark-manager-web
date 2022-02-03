use std::env;
use std::future::Future;
use std::pin::Pin;

pub mod command;

use crate::create_command;
use command::execute_command;

pub trait ArkCommand {
    fn command(&self) -> String;
    fn additional_args(&self) -> Vec<String>;
    fn invoke<'a>(&self, args: Option<Vec<String>>) -> Pin<Box<dyn Future<Output = ()> + 'a>> {
        let mut arguments = self.additional_args();
        if let Some(additional) = args {
            let mut additional_args = additional;
            arguments.append(&mut additional_args);
        }
        Box::pin(execute_command(self.command(), arguments))
    }
}

pub fn parse_env_to_args(var_name: &str) -> Vec<String> {
    match env::var(var_name) {
        Ok(value) => value
            .split_whitespace()
            .map(String::from)
            .collect::<Vec<String>>(),
        Err(_) => vec![],
    }
}

// Commands

create_command! {
    struct StartCommand {},
    "start",
    "ADDITIONAL_START_ARGS"
}

create_command! {
    struct StopCommand {},
    "stop",
    "ADDITIONAL_STOP_ARGS"
}

create_command! {
    struct RestartCommand {},
    "restart",
    "ADDITIONAL_RESTART_ARGS"
}

create_command! {
    struct UpdateCommand {},
    "update",
    "ADDITIONAL_UPDATE_ARGS"
}

// Disabled due to hanging
// create_command! {
//     struct CheckUpdateCommand {},
//     "checkupdate",
//     "ADDITIONAL_CHECK_UPDATE_ARGS"
// }

create_command! {
    struct CheckModUpdateCommand {},
    "checkmodupdate",
    "ADDITIONAL_CHECK_MOD_UPDATE_ARGS"
}

create_command! {
    struct StatusCommand {},
    "status",
    "ADDITIONAL_STATUS_ARGS"
}

create_command! {
    struct InstallCommand {},
    "install",
    "ADDITIONAL_INSTALL_ARGS"
}
