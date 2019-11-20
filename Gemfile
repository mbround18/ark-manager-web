# frozen_string_literal: true

require 'rubygems'

source 'https://rubygems.org'

group :develop do
  agent_gemfile = './agent/Gemfile'
  if File.exists?(agent_gemfile) then
    eval File.read(agent_gemfile), nil, agent_gemfile
  end
end

gem 'eventmachine', platform: 'ruby'

gem 'sinatra'
gem 'puma'
gem 'grape'
gem 'rack'
gem 'rake'
gem 'oj'
gem 'tzinfo-data'
gem 'highline'
gem 'oga'
gem 'mime-types', require: 'mime/types/full'
gem 'rdiscount'
gem 'foreman'
gem 'dotenv'
gem 'rack-cors'
gem 'faye-websocket'
gem 'redis'