require 'sinatra'
require 'grape'

class ArkManagerAPI < Grape::API
  version 'v1', using: :header, vendor: 'round18gaming'
  format :json
  prefix :api

  get :hello do
    { hello: 'world' }
  end
	
  post 'run-command' do
    if params.has_key? :cmd
      `arkmanager update --update-mods`
       'success'
    else
       error!('401 Unauthorized', 401)
    end
  end

  get '*' do
    halt 401, "Unauthorized/Incorrect URL.\nThis Service belongs to only authorized personel of Round 18 Gaming"
  end

end

class ArkManagerWeb < Sinatra::Base
  enable :sessions
  set :session_store, Rack::Session::Pool
  set :haml, :format => :html5
  set :public_folder, './public'
  get '/' do
    haml :index
  end
end
