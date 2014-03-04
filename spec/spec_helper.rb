require 'rubygems'
require 'bundler'

Bundler.setup
require 'rack/test'
require File.expand_path '../../app.rb', __FILE__

ENV["RACK_ENV"] ||= 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end

  def session
    last_request.env['rack.session']
  end
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.include RSpecMixin
end
