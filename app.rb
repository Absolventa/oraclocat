require 'sinatra'
require 'sinatra/url_for'
require 'sinatra/static_assets'
require 'haml'
require './environments'
require './developers'

enable :sessions

# Public
get '/' do
  @client_id = '0e9c4388720416dadd00'
  haml :index
end

get '/aleaiactaest' do
  @merger = choose_from DEVELOPERS
  haml :index
end

get '/callback' do
  session[:code] = params[:code]
end

# Helpers
helpers do
  def choose_from(collection)
    collection.keys[rand(collection.keys.length)-1]
  end
end
