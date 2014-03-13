require 'spec_helper'

describe Oraclocat::Helpers do

  def helper
    @helper ||= Class.new do
      include Oraclocat::Helpers
    end.new
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
