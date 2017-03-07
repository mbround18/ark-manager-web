WORKING_DIR = File.dirname(File.expand_path('..', __FILE__))
working_directory WORKING_DIR

pid  WORKING_DIR + '/tmp/unicorn.pid'
stderr_path WORKING_DIR + '/log/unicorn.stderr.log'
stdout_path WORKING_DIR + '/log/unicorn.stderr.log'

worker_processes 1

listen '0.0.0.0:8080'
