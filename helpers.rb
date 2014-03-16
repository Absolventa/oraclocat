module Oraclocat
  module Helpers

    def access_token
      session['access_token']
    end

    def current_user
      @current_user ||= github_client.user if access_token
    end

    def github_client
      @github_client ||= GH::Client.new(
        Sinatra::Application.settings.client_id,
        Sinatra::Application.settings.client_secret,
        access_token
      )
    end

    def github_login_path
      client_id = Sinatra::Application.settings.client_id
      scopes    = Sinatra::Application.settings.github_scopes.join(',')
      "https://github.com/login/oauth/authorize?scope=#{scopes}&client_id=#{client_id}"
    end

  end
end
