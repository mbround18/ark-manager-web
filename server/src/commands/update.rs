#[derive(serde::Deserialize)]
pub struct UpdateOptions {
    pub force: Option<bool>,
    pub validate: Option<bool>,
    pub backup: Option<bool>,
    pub warn: Option<bool>,
    pub save_world: Option<bool>,
    pub update_mods: Option<bool>,
}

impl Into<Option<Vec<String>>> for UpdateOptions {
    fn into(self) -> Option<Vec<String>> {
        let mut options = Vec::new();
        // Implement force
        if let Some(force) = self.force {
            if force {
                options.push("--force")
            }
        }

        // Implement validate
        if let Some(validate) = self.validate {
            if validate {
                options.push("--validate")
            }
        }

        // Implement backup
        if let Some(backup) = self.backup {
            if backup {
                options.push("--backup")
            }
        }

        // Implement save_world
        if let Some(save_world) = self.save_world {
            if save_world {
                options.push("--saveworld")
            }
        }

        // Implement warn
        if let Some(warn) = self.warn {
            if warn {
                options.push("--warn")
            }
        }

        // Implement update mods
        if let Some(update_mods) = self.update_mods {
            if update_mods {
                options.push("--update-mods")
            }
        }

        // Collect into a Vec<String>
        if options.is_empty() {
            None
        } else {
            let ret_options: Vec<String> = options.iter().map(|s| format!("{}", s)).collect();
            Some(ret_options)
        }
    }
}
