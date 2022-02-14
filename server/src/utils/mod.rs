pub mod unix_socket;

use std::path::Path;

pub fn strip_ansi(data: &str) -> String {
    String::from_utf8(strip_ansi_escapes::strip(data).unwrap()).unwrap()
}

pub fn is_ark_installed() -> bool {
    use std::env;
    match env::var("HOME") {
        Ok(home) => Path::new(&format!(
            "{}/ARK/ShooterGame/Binaries/Linux/ShooterGameServer",
            home
        ))
        .exists(),
        Err(_) => Path::new("/ARK/ShooterGame/Binaries/Linux/ShooterGameServer").exists(),
    }
}
