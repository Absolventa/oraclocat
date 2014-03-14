module GH
  class Client

    attr_reader :client_id, :client_secret

    attr_accessor :access_token

    def initialize(client_id, client_secret, access_token = nil)
      @client_id, @client_secret, @access_token = client_id, client_secret, access_token
    end

    def get_access_token!(code)
      result = RestClient.post(
        'https://github.com/login/oauth/access_token',
        {
          client_id:     client_id,
          client_secret: client_secret,
          code:          code
        },
        accept: :json
      )

      self.access_token = JSON.parse(result)['access_token']
    end

    def fetch url
      result = RestClient.get(
        url,
        {
          params: {
            client_id:     client_id,
            client_secret: client_secret
          },
          accept: :json,
          'Authorization' => "token #{access_token}"
        }
      )
      JSON.parse(result)
    end

    def user
      if access_token
        @user ||= begin
                    result = fetch 'https://api.github.com/user'
                    # OPTIMIZE Put me into a seperate class
                    Struct.new(:avatar_url, :email, :login, :name).new.tap do |user|
                      user.avatar_url = result['avatar_url']
                      user.email      = result['email']
                      user.login      = result['login']
                      user.name       = result['name']
                    end
                  end
      end

    end

  end
end
