$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'sinatra'
require 'sinatra/url_for'
require 'sinatra/static_assets'
require './helpers'
require './developers'
require 'gh/org'
require 'gh/user'
require 'gh/client'

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
  haml :index
end

get '/aleaiactaest' do
  @merger = choose_from DEVELOPERS
  haml :index
end

get '/callback' do
  session[:access_token] = github_client.get_access_token! params[:code]
  redirect '/orgs'
end

get '/orgs' do
  haml :orgs
end

get '/orgs/:org' do
  if access_token
    org = current_user.orgs.detect{|o| o.login == params[:org]}
    full_repos = github_client.fetch "https://api.github.com/orgs/#{org.login}/repos"

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
  include Oraclocat::Helpers

  def choose_from(collection)
    collection.keys[rand(collection.keys.length)-1]
  end
end
