use shared::SOCKET_PATH;

pub fn send_command(command: String) -> std::io::Result<usize> {
    use std::io::Write;
    let mut stream = std::os::unix::net::UnixStream::connect(SOCKET_PATH).unwrap();
    stream.write(command.as_bytes())
}
