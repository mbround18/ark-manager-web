#[derive(serde::Deserialize)]
pub struct UpdateOptions {
    pub force: Option<bool>,
    pub validate: Option<bool>,
    pub backup: Option<bool>,
    pub warn: Option<bool>,
    pub save_world: Option<bool>,
    pub update_mods: Option<bool>,
}

impl UpdateOptions {
    pub(crate) fn to_vec(&self) -> Option<Vec<String>> {
        let _ = self;
        None
    }
}
