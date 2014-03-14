module GH
  class Org

    attr_reader :login, :id, :url, :repos_url, :events_url, :members_url, :public_members_url, :avatar_url

    def initialize(attributes = {})
      attributes.each do |attribute, value|
        instance_variable_set "@#{attribute}", value
      end
    end

  end
end
