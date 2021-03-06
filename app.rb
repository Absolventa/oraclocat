$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'sinatra'
require 'sinatra/url_for'
require 'sinatra/static_assets'
require './helpers'
require 'gh/org'
require 'gh/user'
require 'gh/client'
require 'gh/request'

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
    issues = github_client.fetch "https://api.github.com/orgs/#{org.login}/issues?filter=created&state=open"

    @issues = issues.select { |issue|
      issue.fetch('pull_request', {})['html_url'] && !issue['assignee']
    }.map { |issue|
      repo = issue['repository']['name']
      collaborators_url = "https://api.github.com/repos/#{org.login}/#{repo}/collaborators"
      collaborators     = github_client.fetch(collaborators_url).map { |collab|
        collab['login'] if collab['login'] != current_user.login
      }.compact
      issue.merge('merger' => collaborators.sample)
    }
    haml :pull_requests
  else
    redirect '/'
  end
end

post '/orgs/:org/:repo/:issue/assign/:assignee' do
  if access_token
    # Post a comment
    url  = "https://api.github.com/repos/#{params[:org]}/#{params[:repo]}/issues/#{params[:issue]}/comments"
    body = { body: "Oraclocat has spoken: @#{params[:assignee]} will merge this PR!" }.to_json
    GH::Request.post(url, payload: body, headers: { content_type: :json }, access_token: access_token)

    # Assign issue
    url    = "https://api.github.com/repos/#{params[:org]}/#{params[:repo]}/issues/#{params[:issue]}"
    body   = { assignee: params[:assignee] }.to_json
    result = GH::Request.patch(url, payload: body, headers: { content_type: :json }, access_token: access_token)

    @url = JSON.parse(result)['url']
    "Assigned! <a href='#{@url}'>@#{params[:assignee]} was assigned!</a>"
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
end
