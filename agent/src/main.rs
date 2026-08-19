mod ark_manager;
mod utils;

use ark_manager::commands::execute_command;
use shared::{AgentCommand, Command, StateStorage, DEFAULT_LOG, SOCKET_PATH};
use std::fs::{create_dir_all, remove_file, write};
use std::io::{BufRead, BufReader};
use std::os::unix::net::{UnixListener, UnixStream};
use std::path::Path;
use std::thread;

fn handle_client(stream: UnixStream) {
    let stream = BufReader::new(stream);
    for line in stream.lines() {
        let input = line.unwrap();
        let input_command: AgentCommand = match serde_json::from_str(&input) {
            Ok(cmd) => cmd,
            Err(e) => {
                println!("Failed to parse command: {e}");
                continue;
            }
        };

        println!("Received {}", &input);
        match input_command.command_type() {
            Ok(cmd) => {
                let (name, args) = match cmd {
                    Command::Start => ("start", input_command.command_arguments),
                    Command::Stop => ("stop", None),
                    Command::Restart => ("restart", None),
                    Command::Update => ("update", input_command.command_arguments),
                    Command::Status => ("status", input_command.command_arguments),
                    Command::Install => ("install", None),
                };
                execute_command(String::from(name), args.unwrap_or_default());
            }
            Err(_) => {
                println!("No command found for input: {}", input);
            }
        }
    }
}

fn main() {
    let socket = Path::new(SOCKET_PATH);
    let log = Path::new(DEFAULT_LOG);
    create_dir_all("/tmp/ark-manager-web/").unwrap_or(());
    if !log.exists() {
        write(log, "").unwrap();
    }
    if socket.exists() {
        remove_file(socket).unwrap();
    }

    StateStorage::default().write();

    let listener = UnixListener::bind(SOCKET_PATH).unwrap();
    println!("Agent bound to: {}", &socket.to_str().unwrap());

    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                thread::spawn(move || handle_client(stream));
            }
            Err(err) => {
                println!("Error: {}", err);
                break;
            }
        }
    }
}
