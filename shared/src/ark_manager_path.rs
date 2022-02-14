pub fn ark_manager_path() -> String {
    use which::which;
    match which("arkmanager") {
        Err(_) => {
            println!("-----------------------------------------------------------------------------------------------");
            println!("Failed to find 'arkmanager' in path");
            println!("You can install it via: https://github.com/arkmanager/ark-server-tools");
            println!("If this is the ark-manager-web docker image by mbround18, \nplease log an issue at: https://github.com/mbround18/ark-manager-web/issues/new");
            println!("-----------------------------------------------------------------------------------------------");
            panic!("Please install arkmanager.")
        }
        Ok(path) => String::from(path.to_str().unwrap()),
    }
}
