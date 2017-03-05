WORKING_DIR = File.dirname(File.expand_path('..', __FILE__))
working_directory WORKING_DIR

stderr_path WORKING_DIR + '/log/unicorn.stderr.log'
stdout_path WORKING_DIR + '/log/unicorn.stderr.log'

worker_processes 1

listen "#{ENV.fetch('LISTENING_IP', '0.0.0.0')}:#{ENV.fetch('LISTENING_PORT', '8080')}"
