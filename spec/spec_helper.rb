require 'rubygems'
require 'bundler'

Bundler.setup
require 'rack/test'
require 'webmock/rspec'
require File.expand_path '../../app.rb', __FILE__

ENV["RACK_ENV"] ||= 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end

  def session
    last_request.env['rack.session']
  end
end

module NetHttpStubs
  def stub_github_access_token_endpoint!
    stub_request(:post, 'https://github.com/login/oauth/access_token').
      with(
        client_id: app.settings.client_id,
        client_secret: app.settings.client_secret,
        code: code
      ).
      to_return(status: 200, body: { access_token: access_token }.to_json)
  end
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.include RSpecMixin
  config.include NetHttpStubs
end
