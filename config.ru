require_relative 'app'

use Rack::Session::Cookie, :key => 'rack.session',
                           :domain => 'ark.r18g.us',
                           :path => '/',
                           :expire_after => 2592000,
                           :secret => 'Exde#$LTj-aBRaRU?JH3L54S$Z%TrNZntV5h%d3cr?p34K4u&M8mS8Ab&t5P@aVk'


run Rack::Cascade.new [ArkManagerAPI, ArkManagerWeb]
