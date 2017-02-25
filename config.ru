require 'rack'
require 'securerandom'
require 'dalli'
require 'rack/session/dalli'
require 'rufus-scheduler'
require_relative 'ark_manager_web'
require_relative 'ark_manager_api'
WORKING_DIR = File.dirname(__FILE__)
ARK_MANAGER_CLI = find_executable 'arkmanager'
$scheduler = Rufus::Scheduler.new



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
