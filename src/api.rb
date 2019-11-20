require 'grape'

class APIApp < Grape::API
  version 'v1', using: :path
  format :json
  prefix :api
  get :instances do
    [
      {id: 12343, host: '127.0.0.1', name: 'main'},
      {id: 22343, host: '127.0.0.1', name: 'rag'}
    ]
  end
  post :checkin do

  end
end
