require 'spec_helper'
require 'securerandom'

describe "Oraclocat" do
  it "accesses the front page" do
    get '/'
    expect(last_response).to be_ok
  end

  describe 'GET /callback' do
    it 'takes a session code and asks GH for an access token' do
      code = SecureRandom.hex(8)

      expect(RestClient).to receive(:post).
        with('https://github.com/login/oauth/access_token',
          {
            client_id: CLIENT_ID,
            client_secret: CLIENT_SECRET,
            code: code
          },
          accept: :json
        ).and_return('my_access_token')

      get "/callback?code=#{code}"
      expect(session[:code]).to eql code
    end
  end

end
