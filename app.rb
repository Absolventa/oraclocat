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

Dotenv.load

enable :sessions

configure do
  set :client_id,     ENV['GH_CLIENT_ID']
  set :client_secret, ENV['GH_CLIENT_SECRET']
  set :github_scopes, ['user', 'read:org', 'repo']
end

# Public
get '/' do
  @ghc = GithubClient.new(settings.client_id, settings.client_secret, session['access_token'])
  haml :index
end

get '/aleaiactaest' do
  @ghc = GithubClient.new(settings.client_id, settings.client_secret, session['access_token'])
  @merger = choose_from DEVELOPERS
  haml :index
end

get '/callback' do
  ghc = GithubClient.new(settings.client_id, settings.client_secret)
  session[:access_token] = ghc.get_access_token! params[:code]
end

get '/repos' do
  if session['access_token']
    ghc = GithubClient.new(settings.client_id, settings.client_secret, session['access_token'])
    full_repos = ghc.fetch 'https://api.github.com/orgs/Absolventa/repos'

    @repo_names = full_repos.map { |repo| repo['name'] }.sort
    haml :repos
  else
    redirect '/'
  end
end

get '/logout' do
  session.clear
  redirect '/'
end

# Helpers
helpers do
  def choose_from(collection)
    collection.keys[rand(collection.keys.length)-1]
  end

  def github_login_path
    client_id = Sinatra::Application.settings.client_id
    scopes    = Sinatra::Application.settings.github_scopes.join(',')
    "https://github.com/login/oauth/authorize?scope=#{scopes}&client_id=#{client_id}"
  end
end
