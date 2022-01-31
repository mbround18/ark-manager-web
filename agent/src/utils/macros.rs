#[macro_export]
macro_rules! create_command {
    (
           $vis:vis struct $struct_name:ident { },
           $a:expr,
           $b:expr) => {
        pub struct $struct_name {}
        impl crate::commands::ArkCommand for $struct_name {
            fn command(&self) -> String {
                String::from($a)
            }

            fn additional_args(&self) -> Vec<String> {
                crate::commands::parse_env_to_args($b)
            }
        }
        impl Default for $struct_name {
            fn default() -> Self {
                $struct_name {}
            }
        }
    };
}
