require "sinatra/base"
require 'mime/types'
require 'pathname'
require "rdiscount"
require 'em/pure_ruby'
require 'faye/websocket'
require_relative '../config/environment'

class WebApp < Sinatra::Base
  helpers do
    def fetch_file_path(file_name = 'index.html')
      File.expand_path(File.join(File.dirname(__FILE__ ), '..', 'dist', file_name ))
    end
  end

  get '/' do
    if NODE_ENV == 'development' || NODE_ENV == 'external'
      redirect FRONTEND_EXTERNAL_URL
    end
    index_path = fetch_file_path
    if File.exist?(index_path)
      File.read(index_path)
    else
      markdown :install
    end
  end

  get '/asset/:path' do
    file_path = fetch_file_path(params[:path])
    if File.exist?(file_path)
      file_type = MIME::Types.type_for(file_path).first.to_s
      content_type file_type
      File.read(file_path)
    else
      status 404
    end
  end

  
  get '/stream', provides: 'text/event-stream' do
    stream :keep_open do |out|
      puts out
      settings.connections << out
      out.callback { settings.connections.delete(out) }
    end
  end
end