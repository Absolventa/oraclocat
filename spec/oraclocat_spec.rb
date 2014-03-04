require 'spec_helper'
require 'securerandom'

describe "Oraclocat" do
  it "accesses the front page" do
    get '/'
    expect(last_response).to be_ok
  end

  describe 'GET /callback' do
    it 'provides a callback URI' do
      get '/callback'
      expect(last_response).to be_ok
    end

    it 'stores the provided code in the session' do
      code = SecureRandom.hex(8)
      get "/callback?code=#{code}"
      expect(session[:code]).to eql code
    end
  end

end
