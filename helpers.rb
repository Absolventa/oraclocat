module Oraclocat
  module Helpers

    def access_token
      session['access_token']
    end

    def github_login_path
      client_id = Sinatra::Application.settings.client_id
      scopes    = Sinatra::Application.settings.github_scopes.join(',')
      "https://github.com/login/oauth/authorize?scope=#{scopes}&client_id=#{client_id}"
    end

  end
end
