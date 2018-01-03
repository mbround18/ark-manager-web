require 'oj'
require 'json'
require 'mkmf'
require 'dalli'
require 'logger'
require 'base64'
require 'rufus-scheduler'

WORKING_DIR          = File.dirname(File.expand_path('..', __FILE__)) unless defined?(WORKING_DIR)
EGREP_EXEC           = find_executable 'egrep'
CURL_EXEC            = find_executable 'curl'
USER_HOME            = Dir.home unless defined?(USER_HOME)
ARK_MANAGER_CLI_PATH = "#{USER_HOME}/bin" unless defined?(ARK_MANAGER_CLI_PATH)
RACK_ENV             = ENV.fetch('RACK_ENV', 'development')

memcache_port = '11211'
memcache_address = 'localhost'
if File.exists?("#{WORKING_DIR}/config/env_config.json")
  hash = Oj.load_file("#{WORKING_DIR}/config/env_config.json", Hash.new)
  hash.each_pair { |key,value|  ENV[key] = value  }
  memcache_port        = ENV['memcache_port'] || memcache_port
  memcache_address     = ENV['memcache_address'] || memcache_address
  ARK_MANAGER_CLI_PATH = ENV['arkmanager_path'] || ARK_MANAGER_CLI_PATH
end

ARK_MANAGER_CLI = find_executable('arkmanager', ARK_MANAGER_CLI_PATH) unless defined?(ARK_MANAGER_CLI)
DOMAIN_NAME     = ENV.fetch('DOMAIN_NAME', 'localhost')
ENV["TZ"] = ENV.fetch("TZ", "Etc/UTC")

raise 'I was unable to find arkmanager in your path!! please run "bundle exec rake install:server_tools"' unless ARK_MANAGER_CLI
raise 'I was unable to find memcached!!! please have your system administrator install memcached' unless find_executable('memcached')

$logger = Logger.new(STDOUT)
$logger.datetime_format = '%m-%d-%Y %H:%M:%S'
$logger.progname = 'web interface'
if RACK_ENV == 'production'
  $logger.level = Logger::WARN
else
  $logger.level = Logger::DEBUG
end

$scheduler = Rufus::Scheduler.new unless defined?($scheduler)
$dalli_cache = Dalli::Client.new(format('%s:%s', memcache_address, memcache_port), { namespace: 'boop_on_your_nose', compress: true }) unless defined?($dalli_cache)
$dalli_cache.flush_all


$dalli_cache.set('arkmanager_updates_running', false)

if File.exists?("#{WORKING_DIR}/config/schedules.json")
  Oj.load_file("#{WORKING_DIR}/config/schedules.json", Hash.new).each_pair do |key, value|
    $dalli_cache.set(key, value)
  end
else
  $dalli_cache.set('run_automatic_start', true)
  $dalli_cache.set('mod_update_check_schedule', true)
  $dalli_cache.set('server_update_check_schedule', true)
  File.write("#{WORKING_DIR}/config/schedules.json", "{\n\t\"run_automatic_start\": true,\n\t\"mod_update_check_schedule\": true,\n\t\"server_update_check_schedule\": true\n}")
end

unless File.exist?("#{WORKING_DIR}/config/mod_list.json")
  File.write("#{WORKING_DIR}/config/mod_list.json", "{\n}")
end
