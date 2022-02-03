mod ark_manager;
mod errors;
mod utils;

use crate::ark_manager::commands;
pub use crate::utils::logger::{agent_log, log};
use crate::utils::{
    ark_manager_path::ark_manager_path,
    constants::{DEFAULT_LOG, SOCKET_PATH},
    AgentCommand, Command,
};
use std::fs::{create_dir, remove_file, write};
use std::io::{BufRead, BufReader};
use std::os::unix::net::{UnixListener, UnixStream};
use std::path::Path;
use std::thread;

async fn handle_client(stream: UnixStream) {
    let stream = BufReader::new(stream);
    for line in stream.lines() {
        let input = line.unwrap();
        let input_command: AgentCommand = serde_json::from_str(&input).unwrap();

        println!("Received {}", &input);
        match input_command.command_type() {
            Ok(cmd) => {
                use crate::commands::{
                    ArkCommand, InstallCommand, RestartCommand, StartCommand, StatusCommand,
                    StopCommand, UpdateCommand,
                };
                match cmd {
                    Command::Start => StartCommand::default().invoke(None),
                    Command::Stop => StopCommand::default().invoke(None),
                    Command::Restart => RestartCommand::default().invoke(None),
                    Command::Update => UpdateCommand::default().invoke(None),
                    Command::Status => {
                        StatusCommand::default().invoke(input_command.command_arguments)
                    }
                    Command::Install => InstallCommand::default().invoke(None),
                }
                .await
            }
            Err(_) => {
                println!("No command found for input: {}", input);
            }
        }
    }
}

fn main() {
    // Check if path is available
    ark_manager_path();

    let socket = Path::new(SOCKET_PATH);
    let log = Path::new(DEFAULT_LOG);
    create_dir("/tmp/ark-manager-web/").unwrap_or(());
    if !log.exists() {
        write(log, "").unwrap()
    }
    if socket.exists() {
        remove_file(socket).unwrap()
    }
    let listener = UnixListener::bind(SOCKET_PATH).unwrap();
    println!("Agent bound! Bound to: {}", &socket.to_str().unwrap());

    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                use futures::executor::block_on;
                thread::spawn(move || block_on(handle_client(stream)));
            }
            Err(err) => {
                println!("Error: {}", err);
                break;
            }
        }
    }
}
