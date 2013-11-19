require 'sinatra'
require 'sinatra/url_for'
require 'sinatra/static_assets'
require 'haml'
require './environments'
require './developers'

# Public
get '/' do
  # ToDo: load array from file to make it open source?
  @merger    = choose_from DEVELOPERS
  haml :index
end

# Helpers
helpers do
  def choose_from(collection)
    index  = rand(collection.keys.length)
    key = collection.keys[index-1]
    key
  end
end
