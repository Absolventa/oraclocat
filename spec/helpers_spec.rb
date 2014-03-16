require 'spec_helper'

describe Oraclocat::Helpers do

  def helper
    @helper ||= Class.new do
      include Oraclocat::Helpers
      def session
        {}
      end
    end.new
  end

  describe '#access_token' do
    it 'returns nil if session does not contain access_token' do
      expect(helper).to receive(:session).and_return({})
      expect(helper.access_token).to be_nil
    end

    it 'returns true if session contains access_token' do
      expect(helper).to receive(:session).and_return('access_token' => 'foobarbaz')
      expect(helper.access_token).to eql 'foobarbaz'
    end
  end

  describe '#current_user' do
    it 'returns nil if access token is missing' do
      helper.stub(access_token: nil)
      expect(helper.current_user).to be_nil
    end

    it 'returns a github client instance if access token is available' do
      helper.stub(access_token: 'foobar')
      expect_any_instance_of(GH::User).to receive(:fetch!)
      expect(helper.current_user).to be_instance_of GH::User
    end
  end

  describe '#github_client' do
    it 'returns a GH::Client instance' do
      expect(helper.github_client).to be_instance_of GH::Client
    end
  end

  describe '#github_login_path' do
    it 'includes app credentials in authorization link' do
      expect(app.settings).to receive(:client_id).and_return 'CLIENTID'
      expect(app.settings).to receive(:github_scopes).and_return ['foo', 'bar']
      expect(helper.github_login_path).
        to eql "https://github.com/login/oauth/authorize?scope=foo,bar&client_id=CLIENTID"
    end
  end

end
