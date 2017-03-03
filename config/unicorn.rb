WORKING_DIR = File.dirname(File.expand_path('..', __FILE__))
working_directory WORKING_DIR

worker_processes 2

stderr_path WORKING_DIR + '/log/unicorn.stderr.log'
stdout_path WORKING_DIR + '/log/unicorn.stderr.log'

pid WORKING_DIR + '/tmp/unicorn.pid'

if ENV.fetch('RACK_ENV', 'development') == 'production'
  listen '127.0.0.1:8080'
else
  listen '0.0.0.0:8080'
end


