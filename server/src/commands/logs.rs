use linemux::Line;

#[derive(serde::Serialize, serde::Deserialize)]
pub struct OutputLogLine {
    source: String,
    message: String,
}

impl From<Line> for OutputLogLine {
    fn from(line: Line) -> Self {
        OutputLogLine {
            source: format!("{}", &line.source().display()),
            message: line.line().to_string(),
        }
    }
}

impl ToString for OutputLogLine {
    fn to_string(&self) -> String {
        serde_json::to_string(self).unwrap()
    }
}
