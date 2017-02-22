require 'sinatra'
require 'grape'

class ArkManagerAPI < Grape::API
  version 'v1', using: :header, vendor: 'round18gaming'
  format :json
  prefix :api

  get :hello do
    { hello: 'world' }
  end
end

class ArkManagerWeb < Sinatra::Base
  get '/' do
    'Hello world.'
  end
end
