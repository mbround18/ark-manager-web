require 'json'
require 'highline/import'

env_config_path = "#{WORKING_DIR}/config/env_config.json"

desc 'Configure the env_config.json file.'
task :configure do
	cli = HighLine.new
	expected_keys = %i[ARKMANAGER_PATH ARK_INSTANCE_NAME MEMCACHE_ADDRESS MEMCACHE_PORT]


	if File.exist?(env_config_path)
		file = File.read(env_config_path)
		config = JSON.parse!(file, symbolize_names: true)
		(expected_keys - config.keys).each do |e|
			config[e] = cli.ask("Unfortunately your config does not have the value #{e.to_s}\n What would you like #{e.to_s} to be?   ")
		end

		cli.choose do |menu|
			menu.prompt = 'Would you like to change any of the following options?  '
			config.keys.each {|e| menu.choice(e) { config[e] = cli.ask("What would you like #{e.to_s} to be?  ") } }
			menu.choice(:nothing) { cli.say('Alrighty...') }
			menu.default = :nothing
		end
	else
		cli.say('A config file has not been found! Creating one now..')
		config = {
			ARKMANAGER_PATH: cli.ask('What is the arkmanager path?  ') { |q| q.default = "#{Dir.home}/bin" },
			ARK_INSTANCE_NAME: cli.ask('What is the ark instance name?  ') { |q| q.default = 'main' },
			ARK_CONFIG_FOLDER: cli.ask('What is the config path?  ') { |q| q.default = "#{Dir.home}/.config/arkmanager" },
			MEMCACHE_ADDRESS:cli.ask('What is the memcached ip address?  ') { |q| q.default = '127.0.0.1' },
			MEMCACHE_PORT: cli.ask('What is the memcached port?  ', Integer) { |q| q.default = '11211' },
			ADDRESS: cli.ask('What is the webserver ip address?  ') { |q| q.default = '127.0.0.1' },
			PORT: cli.ask('What is the webserver port?  ', Integer) { |q| q.default = '8080' }
		}
	end

	File.open(env_config_path, 'w') { |file| file.write(JSON.pretty_generate(config)) }
end
