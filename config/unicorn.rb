require 'json'
WORKING_DIR = File.dirname(File.expand_path('..', __FILE__))
working_directory WORKING_DIR

pid  WORKING_DIR + '/tmp/unicorn.pid'
stderr_path WORKING_DIR + '/log/unicorn.stderr.log'
stdout_path WORKING_DIR + '/log/unicorn.stderr.log'

worker_processes 1

# this is default ones
port = '8080'
address = '0.0.0.0'

env_config_path = "#{WORKING_DIR}/config/env_config.json"

if File.exist?(env_config_path)
	file = File.read(env_config_path)
	hash = JSON.parse!(file, symbolize_names: true)
  # hash = Oj.load_file("#{WORKING_DIR}/config/env_config.json", Hash.new)
  port = hash[:port] || port
  address = hash[:address] || address
end

listen format('%s:%s', address, port)
