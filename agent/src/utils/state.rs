use crate::utils::constants::STATE_STORAGE_PATH;
use serde::{Deserialize, Serialize};
use std::{str::FromStr, string::String};

#[derive(Serialize, Deserialize, Default)]
pub struct StateStorage {
    pub start: bool,
    pub stop: bool,
    pub restart: bool,
    pub update: bool,
    pub install: bool,
}

impl ToString for StateStorage {
    fn to_string(&self) -> String {
        serde_json::to_string_pretty(self).unwrap()
    }
}

impl FromStr for StateStorage {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(match serde_json::from_str(s) {
            Ok(state_storage) => state_storage,
            Err(_) => StateStorage::default(),
        })
    }
}

impl StateStorage {
    #[allow(dead_code)]
    pub fn read() -> StateStorage {
        use std::{
            fs::{read, write},
            path::Path,
        };
        if !Path::new(STATE_STORAGE_PATH).exists() {
            write(STATE_STORAGE_PATH, StateStorage::default().to_string()).unwrap();
        }
        let state_string = String::from_utf8(read(STATE_STORAGE_PATH).unwrap()).unwrap();
        StateStorage::from_str(&state_string).unwrap()
    }
    #[allow(dead_code)]
    pub fn write(&self) {
        std::fs::write(STATE_STORAGE_PATH, self.to_string()).unwrap();
    }

    #[allow(dead_code)]
    pub fn by_key(&self, key: &str) -> bool {
        match key {
            "start" => self.start,
            "stop" => self.stop,
            "restart" => self.restart,
            "update" => self.update,
            "install" => self.install,
            _ => unreachable!("Unable to access attribute"),
        }
    }
    #[allow(dead_code)]
    pub fn set_by_key(&mut self, key: &str, value: bool) {
        match key {
            "start" => self.start = value,
            "stop" => self.stop = value,
            "restart" => self.restart = value,
            "update" => self.update = value,
            "install" => self.install = value,
            _ => unreachable!("Unable to access attribute"),
        };
    }
}
