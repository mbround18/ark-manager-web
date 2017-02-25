require 'sinatra'
require 'dalli'

class ArkManagerWeb < Sinatra::Base
  enable :sessions
  set :session_store, Rack::Session::Pool
  set :haml, format: :html5
  set :public_folder, './public'
  get '/' do
    haml :index
  end
end
