require 'mkmf'
require 'rack'
require 'securerandom'
require 'dalli'
require 'rack/session/dalli'
require 'rufus-scheduler'
require_relative 'lib/error'

raise ArkManagerWeb::Errors::MemcachedNotFound, 'I was unable to find memcached!!! please have your system administrator install memcached' unless find_executable('memcached')

# Load ENV configuration
require_relative 'config/environment'

env_config_path = "#{WORKING_DIR}/config/env_config.json"
raise ArkManagerWeb::Errors::ConfigNotFound, 'Config file not found!!! please run: bundle exec rake configure' unless File.exist?(env_config_path)
raise ArkManagerWeb::Errors::ArkServerFolderNotFound, 'Ark Server installation not found!!! please run: bundle exec rake install:ark_server' unless Dir.exist?(ARK_SERVER_ROOT)

# Load predefined schedules
require_relative 'lib/predefined_schedules'

# Load web interfaces
require_relative 'api/api_app'
require_relative 'web/web_app'

use Rack::Session::Dalli, cache: Dalli::Client.new
use Rack::Session::Pool, expire_after: 2592000
use Rack::Session::Cookie, key: "#{DOMAIN_NAME}.session",
	domain: DOMAIN_NAME,
	path: '/',
	expire_after: 2592000,
	secret: SecureRandom.hex(64)

use Rack::Protection
use Rack::Protection::RemoteToken
use Rack::Protection::SessionHijacking

run Rack::Cascade.new [
	ApiApp,
	WebApp
]
