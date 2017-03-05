WORKING_DIR = File.dirname(File.expand_path('..', __FILE__))
working_directory WORKING_DIR

worker_processes 1

stderr_path WORKING_DIR + '/log/unicorn.stderr.log'
stdout_path WORKING_DIR + '/log/unicorn.stderr.log'

pid WORKING_DIR + '/tmp/unicorn.pid'

listen "0.0.0.0:#{ENV.fetch('PORT', '8080')}"