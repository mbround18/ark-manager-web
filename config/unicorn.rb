require 'oj'

WORKING_DIR = File.dirname(File.expand_path('..', __FILE__))
working_directory WORKING_DIR

pid  WORKING_DIR + '/tmp/unicorn.pid'
stderr_path WORKING_DIR + '/log/unicorn.stderr.log'
stdout_path WORKING_DIR + '/log/unicorn.stderr.log'

worker_processes 1

# this is default ones
port = '8080'
address = '0.0.0.0'

if File.exists?("#{WORKING_DIR}/config/env_config.json")
  hash = Oj.load_file("#{WORKING_DIR}/config/env_config.json", Hash.new)
  port = hash['port'] || port
  address = hash['address'] || address
end

listen address << ':' << port
