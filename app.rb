require 'sinatra'
require 'sinatra/url_for'
require 'sinatra/static_assets'
require 'haml'
require './environments'

# Public
get '/' do
  developers = %w(Robin Felix Daniel Carsten Alex Markus)
  @merger    = choose_from developers
  haml :index
end

# Helpers
helpers do
  def choose_from(collection)
    index = rand(collection.length)
    collection[index-1]
  end
end
