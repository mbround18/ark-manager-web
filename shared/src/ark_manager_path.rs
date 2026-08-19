/// Retained for backward compatibility. With gsm-instance used as a library,
/// direct shell-outs are no longer needed. Returns an empty string.
#[deprecated(
    since = "2.0.0",
    note = "Use gsm-instance crate directly instead of shelling out to a CLI binary."
)]
pub fn ark_manager_path() -> String {
    String::new()
}
