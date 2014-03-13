require 'spec_helper'

describe Oraclocat::Helpers do

  def helper
    @helper ||= Class.new do
      include Oraclocat::Helpers
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

  describe '#github_login_path' do
    it 'includes app credentials in authorization link' do
      expect(app.settings).to receive(:client_id).and_return 'CLIENTID'
      expect(app.settings).to receive(:github_scopes).and_return ['foo', 'bar']
      expect(helper.github_login_path).
        to eql "https://github.com/login/oauth/authorize?scope=foo,bar&client_id=CLIENTID"
    end
  end

end
