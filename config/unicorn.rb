APP_PATH = "#{Dir.home}/ArkManagerWeb"
working_directory APP_PATH

stderr_path APP_PATH + "/log/unicorn.stderr.log"
stdout_path APP_PATH + "/log/unicorn.stderr.log"

pid APP_PATH + "/tmp/unicorn.pid"

listen "127.0.0.1:8080"
