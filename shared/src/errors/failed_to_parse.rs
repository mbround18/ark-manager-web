use std::fmt;

#[derive(Debug)]
pub struct FailedToParseCommand;

impl fmt::Display for FailedToParseCommand {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Failed to Parse Command")
    }
}

impl std::error::Error for FailedToParseCommand {}
