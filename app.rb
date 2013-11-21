require 'sinatra'
require 'sinatra/url_for'
require 'sinatra/static_assets'
require 'haml'
require './environments'
require './developers'

# Public
get '/' do
  haml :index
end

get '/aleaiactaest' do
  @merger = choose_from DEVELOPERS
  haml :index
end

# Helpers
helpers do
  def choose_from(collection)
    collection.keys[rand(collection.keys.length)-1]
  end
end
