require 'oj'
require 'json'
require 'mkmf'
require 'dalli'
require 'base64'
require 'rufus-scheduler'


WORKING_DIR     = File.dirname(File.expand_path('..', __FILE__)) unless defined?(WORKING_DIR)
EGREP_EXEC      = find_executable 'egrep'
CURL_EXEC       = find_executable 'curl'
USER_HOME       = Dir.home unless defined?(USER_HOME)
ARK_MANAGER_CLI = find_executable('arkmanager', "#{USER_HOME}/bin") unless defined?(ARK_MANAGER_CLI)

if File.exists?("#{WORKING_DIR}/config/env_config.json")
  Oj.load_file("#{WORKING_DIR}/config/env_config.json", Hash.new).each_pair { |key,value|  ENV[key] = value  }
end

DOMAIN_NAME = ENV.fetch('DOMAIN_NAME', 'localhost')


raise 'I was unable to find arkmanager in your path!! please run "bundle exec rake install_server_tools"' unless ARK_MANAGER_CLI
raise 'I was unable to find memcached!!! please have your system administrator install memcached' unless find_executable('memcached')

$scheduler = Rufus::Scheduler.new unless defined?($scheduler)
$dalli_cache = Dalli::Client.new('localhost:11211', { namespace: 'boop_on_your_nose', compress: true }) unless defined?($dalli_cache)
$dalli_cache.flush_all

if File.exists?("#{WORKING_DIR}/config/schedules.json")
  Oj.load_file("#{WORKING_DIR}/config/schedules.json", Hash.new).each_pair do |key, value|
    $dalli_cache.set(key, value)
  end
else
  $dalli_cache.set('mod_update_check_schedule', true)
  $dalli_cache.set('server_update_check_schedule', true)
  File.write("#{WORKING_DIR}/config/schedules.json", "{\n\t\"mod_update_check_schedule\": true,\n\t\"server_update_check_schedule\": true\n}")
end

unless File.exist?("#{WORKING_DIR}/config/mod_list.json")
  File.write("#{WORKING_DIR}/config/mod_list.json", "{\n}")
end