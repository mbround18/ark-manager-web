use gsm_instance::{config::LaunchMode, Instance, InstanceConfig};
use shared::StateStorage;
use std::env;
use std::path::PathBuf;

fn is_command_locked(sub_command: &str) -> bool {
    StateStorage::read().by_key(sub_command)
}

fn set_command_lock(sub_command: &str, value: bool) {
    let mut state = StateStorage::read();
    state.set_by_key(sub_command, value);
    state.write();
}

pub fn build_instance() -> Instance {
    let app_id = env::var("APP_ID")
        .ok()
        .and_then(|v| v.parse::<u32>().ok())
        .unwrap_or(376_030);
    let install_path = env::var("INSTALL_PATH")
        .or_else(|_| env::var("ARK_DIRECTORY"))
        .unwrap_or_else(|_| String::from("/home/steam/ARK"));
    let executable = env::var("EXECUTABLE")
        .unwrap_or_else(|_| String::from("./ShooterGame/Binaries/Linux/ShooterGameServer"));
    let launch_args = env::var("LAUNCH_ARGS")
        .map(|v| v.split_whitespace().map(String::from).collect())
        .unwrap_or_default();
    let install_args = env::var("INSTALL_ARGS")
        .map(|v| v.split_whitespace().map(String::from).collect())
        .unwrap_or_default();
    let skip_validate = env::var("SKIP_VALIDATE")
        .map(|v| v == "true" || v == "1")
        .unwrap_or(false);
    let _ = skip_validate; // field added in a later gsm-instance release

    Instance::new(InstanceConfig {
        app_id,
        name: env::var("NAME").unwrap_or_else(|_| String::from("ARK Server")),
        command: executable,
        install_args,
        launch_args,
        force_windows: false,
        working_dir: PathBuf::from(install_path),
        launch_mode: LaunchMode::Native,
    })
}

pub fn execute_command(sub_command: String, _extra_args: Vec<String>) {
    if is_command_locked(&sub_command) {
        shared::agent_log(format!(
            "Cannot launch command! Already running ArkManager::{}",
            sub_command
        ));
        return;
    }
    set_command_lock(&sub_command, true);
    shared::agent_log(format!("Launching ArkManager::{}", sub_command));

    let instance = build_instance();
    let result: Result<(), String> = match sub_command.as_str() {
        "start" => instance.start().map(|_| ()).map_err(|e| e.to_string()),
        "stop" => instance.stop().map_err(|e| e.to_string()),
        "restart" => instance.restart().map_err(|e| e.to_string()),
        "install" => instance.install().map_err(|e| e.to_string()),
        "update" => instance.update().map_err(|e| e.to_string()),
        other => Err(format!("Unknown command: {other}")),
    };

    match result {
        Ok(()) => shared::agent_log(format!("Complete ArkManager::{}", sub_command)),
        Err(e) => {
            shared::log(
                format!("ArkManager::{}", sub_command),
                format!("Error: {e}"),
            );
            shared::agent_log(format!("Failed ArkManager::{} — {}", sub_command, e));
        }
    }

    set_command_lock(&sub_command, false);
}
