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
      @user ||= if access_token
                  user = GH::User.new(self)
                  user.fetch
                  user
                end
    end

  end
end
