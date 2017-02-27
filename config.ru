require 'rack'
require 'securerandom'
require 'dalli'
require 'rack/session/dalli'
require 'rufus-scheduler'
require_relative 'ark_manager_web'
require_relative 'ark_manager_api'
require_relative 'ark_manager_schedules'
WORKING_DIR = File.dirname(__FILE__) unless defined?(WORKING_DIR)
USER_HOME   = Dir.home unless defined?(USER_HOME)
arkmanager_cli_check = find_executable('arkmanager', "#{USER_HOME}/bin")
ARK_MANAGER_CLI = arkmanager_cli_check unless defined?(ARK_MANAGER_CLI)
raise 'I was unable to find arkmanager in your path!! please run "bundle exec rake install_server_tools"' unless arkmanager_cli_check
raise 'I was unable to find memcached!!! please have your system administrator install memcached' unless find_executable('memcached')

$scheduler = Rufus::Scheduler.new
$dalli_cache = Dalli::Client.new('localhost:11211', { :namespace => 'arkmanager_web', :compress => true }) unless defined?($dalli_cache)
$dalli_cache.flush_all

use Rack::Session::Dalli, cache: Dalli::Client.new
use Rack::Session::Pool, :expire_after => 2592000
use Rack::Protection::RemoteToken
use Rack::Protection::SessionHijacking
use Rack::Session::Cookie, :key => 'rack.session',
                           :domain => 'ark.r18g.us',
                           :path => '/',
                           :expire_after => 2592000,
                           :secret => SecureRandom.hex(64)


run Rack::Cascade.new [ArkManagerAPI, ArkManagerWeb]
