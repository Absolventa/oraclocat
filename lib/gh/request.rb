# vim:foldmethod=indent:foldlevel=3
module GH
  class Request
    class GET
      attr_reader :accept, :access_token, :client_id, :client_secret, :url

      def initialize(url, client_id:, client_secret:, accept: :json, access_token: nil)
        @accept        = accept
        @access_token  = access_token
        @client_id     = client_id
        @client_secret = client_secret
        @url           = url
      end

      def execute
        RestClient::Request.execute(
          method: :get, url: url, headers: headers,
          ssl_version: GH::Request.ssl_version
        )
      end

      def headers
        {
          params: params,
          accept: accept,
          'Authorization' => "token #{access_token}"
        }
      end

      def params
        {
          client_id:     client_id,
          client_secret: client_secret
        }
      end

    end

    class POST
      attr_reader :accept, :access_token, :client_id, :client_secret, :payload, :url

      def initialize(url, client_id:, client_secret:, payload:, accept: :json, access_token: nil, headers: {})
        @accept        = accept
        @access_token  = access_token
        @client_id     = client_id
        @client_secret = client_secret
        @payload       = payload
        @url           = url
        @headers       = headers
      end

      def execute
        RestClient::Request.execute(
          method: :post,
          url: url,
          ssl_version: GH::Request.ssl_version,
          payload: payload.merge(secrets),
          headers: headers
        )
      end

      def headers
        headers = @headers.merge(accept: :json, content_type: :json)
        headers.merge('Authorization' => "token #{access_token}") if access_token
        headers
      end

      def secrets
        {
          client_id:     client_id,
          client_secret: client_secret
        }
      end

    end

    class << self
      def ssl_version
        'TLSv1'.freeze # TODO make this configurable
      end

      def get(*args)
        GET.new(*args).execute
      end

      def post(*args)
        POST.new(*args).execute
      end
    end

  end
end
