require 'pp'
require 'json'
require 'mkmf'
require 'dalli'
require 'logger'
require 'base64'
require 'rufus-scheduler'
require 'net/http'
require_relative '../lib/error'

WORKING_DIR = File.dirname(File.expand_path('..', __FILE__)) unless defined?(WORKING_DIR)
EGREP_EXEC = find_executable 'egrep'
CURL_EXEC = find_executable 'curl'
USER_HOME = Dir.home unless defined?(USER_HOME)
RACK_ENV = ENV.fetch('RACK_ENV', 'development')
SERVER_IP_ADDRESS = Net::HTTP.get URI 'https://api.ipify.org'
memcache_port = '11211'
memcache_address = '127.0.0.1'
env_config_path = "#{WORKING_DIR}/config/env_config.json"

if File.exist?(env_config_path)
	file = File.read(env_config_path)
	hash = JSON.parse!(file, symbolize_names: true)
	hash.each_pair { |key, value| ENV[key.to_s] = value.to_s }
end

ENV['TZ'] = ENV.fetch('TZ', 'Etc/UTC')

ARK_MANAGER_CLI_PATH = ENV.fetch('ARKMANAGER_PATH', "#{USER_HOME}/bin") unless defined?(ARK_MANAGER_CLI_PATH)
ARK_MANAGER_CLI = find_executable('arkmanager', ARK_MANAGER_CLI_PATH) unless defined?(ARK_MANAGER_CLI)
DOMAIN_NAME = ENV.fetch('DOMAIN_NAME', 'localhost')
ARK_INSTANCE_NAME = ENV.fetch('ARK_INSTANCE_NAME', 'main')
INSTANCE_FILE_PATH = format('%s/.config/arkmanager/instances/%s.cfg', USER_HOME, ARK_INSTANCE_NAME)

raise ArkManagerWeb::Errors::InstanceCfgNotFound, "No instance cfg file was found at #{INSTANCE_FILE_PATH}" unless File.exist?(INSTANCE_FILE_PATH)

if File.exist?(env_config_path)
	ark_srv_root_str = File.readlines(INSTANCE_FILE_PATH).find { |line| line =~ /arkserverroot/im }
	ARK_SERVER_ROOT = ark_srv_root_str.split('#').first.strip.gsub!('"', '').gsub!('arkserverroot=', '')
end

raise ArkManagerWeb::Errors::ArkManagerExeNotFound, 'I was unable to find arkmanager in your path!! please run: bundle exec rake install:server_tools' unless ARK_MANAGER_CLI


$logger = Logger.new(STDOUT)
$logger.datetime_format = '%Y-%m-%d %H:%M:%S'
$logger.progname = 'web interface'
if RACK_ENV == 'production'
	$logger.level = Logger::WARN
else
	$logger.level = Logger::DEBUG
end

$scheduler = Rufus::Scheduler.new unless defined?($scheduler)

memcache_address = ENV.fetch('MEMCACHE_ADDRESS', memcache_address)
memcache_port = ENV.fetch('MEMCACHE_PORT', memcache_port)
$dalli_cache = Dalli::Client.new(format('%s:%s', memcache_address, memcache_port), { namespace: 'boop_on_your_nose', compress: true }) unless defined?($dalli_cache)
$dalli_cache.flush_all


$dalli_cache.set('arkmanager_updates_running', false)

scheduler_json_path = "#{WORKING_DIR}/config/schedules.json"
if File.exist?(scheduler_json_path)
	file = File.read(scheduler_json_path)
	json = JSON.parse!(file)
	json.each_pair { |key, value| $dalli_cache.set(key, value) }
else
	$dalli_cache.set('run_automatic_start', true)
	$dalli_cache.set('mod_update_check_schedule', true)
	$dalli_cache.set('server_update_check_schedule', true)
	File.write("#{WORKING_DIR}/config/schedules.json", "{\n\t\"run_automatic_start\": true,\n\t\"mod_update_check_schedule\": true,\n\t\"server_update_check_schedule\": true\n}")
end

unless File.exist?("#{WORKING_DIR}/config/mod_list.json")
	File.write("#{WORKING_DIR}/config/mod_list.json", "{\n}")
end
