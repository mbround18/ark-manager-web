require 'rack'
require 'securerandom'
require_relative 'app'



use Rack::Session::Pool, :expire_after => 2592000
use Rack::Protection::RemoteToken
use Rack::Protection::SessionHijacking
use Rack::Session::Cookie, :key => 'rack.session',
                           :domain => 'ark.r18g.us',
                           :path => '/',
                           :expire_after => 2592000,
                           :secret => SecureRandom.hex(64)


run Rack::Cascade.new [ArkManagerAPI, ArkManagerWeb]
