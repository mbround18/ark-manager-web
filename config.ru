require 'rack'
require 'securerandom'
require 'dalli'
require 'rack/session/dalli'
require 'rufus-scheduler'
require 'oj'

# Load ENV configuration
require_relative 'config/environment'

# Load predefined schedules
require_relative 'lib/predefined_schedules'

# Load web interfaces
require_relative 'api/api_app'
require_relative 'web/web_app'

use Rack::Session::Dalli,  cache: Dalli::Client.new
use Rack::Session::Pool,   expire_after: 2592000
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
