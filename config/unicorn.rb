WORKING_DIR = File.dirname(File.expand_path('..', __FILE__))
working_directory WORKING_DIR

worker_processes 1

listen "#{ENV.fetch('LISTENING_IP', '0.0.0.0')}:#{ENV.fetch('PORT', '8080')}"