module GH
  class User

    class << self
      def endpoint
        @endpoint ||= 'https://api.github.com/user'.freeze
      end
    end

    attr_reader :connector, :avatar_url, :email, :login, :name

    def initialize(connector)
      unless connector.respond_to? :fetch
        raise ArgumentError.new('Connector object must respond to fetch')
      end
      @connector = connector
    end

    def fetch
      result = connector.fetch self.class.endpoint
      %w(avatar_url email login name).each do |attribute|
        self.instance_variable_set "@#{attribute}", result[attribute]
      end
    end

  end
end
