use crate::ark_manager_path;
use crate::utils::StateStorage;
use async_process::{Command, Stdio};
use futures_lite::{io::BufReader, prelude::*};

fn is_command_locked(sub_command: &str) -> bool {
    StateStorage::read().by_key(sub_command)
}

fn set_command_lock(sub_command: &str, value: bool) {
    let mut state = StateStorage::read();
    state.set_by_key(sub_command, value);
    state.write();
}

pub async fn execute_command(sub_command: String, args: Vec<String>) {
    // Use lock to validate & block additional runs.
    if is_command_locked(&sub_command) {
        crate::agent_log(format!(
            "Cannot launch command! Already Running ArkManager::{}",
            sub_command
        ));
        return;
    } else {
        set_command_lock(&sub_command, true);
    }
    let mut additional_args = args.clone();

    // Log to agent log about whats going on.
    crate::agent_log(format!("Launching ArkManager::{}", sub_command));

    // Get arguments and append supplied args
    let mut command_args = vec![String::from(&sub_command)];
    command_args.append(&mut additional_args);

    // Spawn child process
    let mut child = Command::new(ark_manager_path())
        .args(&command_args.to_vec())
        .stdout(Stdio::piped())
        .spawn()
        .unwrap();

    // Ge pid
    // child.id();

    // Split output into lines
    let mut lines = BufReader::new(child.stdout.take().unwrap()).lines();

    // Iterate through lines and log to agent log for FE consumption.
    while let Some(line) = lines.next().await {
        crate::log(
            format!("ArkManager::{}", sub_command),
            line.unwrap().to_string(),
        );
    }

    // Remove lock
    set_command_lock(&sub_command, false);

    // Log that its compelted
    crate::agent_log(format!("Complete ArkManager::{}", sub_command));
}
