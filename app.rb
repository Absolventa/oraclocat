require 'sinatra'
require 'sinatra/url_for'
require 'sinatra/static_assets'
require './environments'
require './developers'
require './github_client'

require 'json'
require 'rubygems'
require 'bundler'
Bundler.require

enable :sessions

CLIENT_ID     = '0e9c4388720416dadd00'
CLIENT_SECRET = '40410be1ec268fd8928c7927d5355c9c98b4098b'

# Public
get '/' do
  @github_scopes = ["user:email", "read:org", "repo"].join(',')
  @client_id = CLIENT_ID
  haml :index
end

get '/aleaiactaest' do
  @merger = choose_from DEVELOPERS
  haml :index
end

get '/callback' do
  ghc = GithubClient.new(CLIENT_ID, CLIENT_SECRET)
  session[:access_token] = ghc.get_access_token! params[:code]
end

get '/repos' do
  if session['access_token']
    ghc = GithubClient.new(CLIENT_ID, CLIENT_SECRET, session['access_token'])
    full_repos = ghc.fetch 'https://api.github.com/orgs/Absolventa/repos'

    @repo_names = full_repos.map { |repo| repo['name'] }.sort
    haml :repos
  else
    redirect '/'
  end
end

# Helpers
helpers do
  def choose_from(collection)
    collection.keys[rand(collection.keys.length)-1]
  end
end
