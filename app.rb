require 'sinatra'
require 'sinatra/url_for'
require 'sinatra/static_assets'
require './environments'
require './developers'

require 'json'
require 'rubygems'
require 'bundler'
Bundler.require

enable :sessions

CLIENT_ID     = '0e9c4388720416dadd00'
CLIENT_SECRET = '40410be1ec268fd8928c7927d5355c9c98b4098b'

# Public
get '/' do
  @client_id = CLIENT_ID
  haml :index
end

get '/aleaiactaest' do
  @merger = choose_from DEVELOPERS
  haml :index
end

get '/callback' do
  session[:code] = params[:code]
  result = RestClient.post('https://github.com/login/oauth/access_token',
                           {:client_id => CLIENT_ID,
                             :client_secret => CLIENT_SECRET,
                             :code => session[:code]},
                             :accept => :json)
  # extract the token and granted scopes
  access_token = JSON.parse(result)['access_token']

end

# Helpers
helpers do
  def choose_from(collection)
    collection.keys[rand(collection.keys.length)-1]
  end
end
