require 'spec_helper'

describe "Oraclocat" do

  describe 'its configuration' do
    it 'gets its client id from the environment' do
      expect(app.settings.client_id).to eql ENV['GH_CLIENT_ID']
    end

    it 'gets its client secret from the environment' do
      expect(app.settings.client_secret).to eql ENV['GH_CLIENT_SECRET']
    end
  end

  it "accesses the front page" do
    get '/'
    expect(last_response).to be_ok
  end

  describe 'GET /callback' do
    it 'takes a session code and asks GH for an access token' do
      code         = 'somecode'
      access_token = 'my_access_token'

      expect(RestClient).to receive(:post).
        with('https://github.com/login/oauth/access_token',
          {
            client_id: app.settings.client_id,
            client_secret: app.settings.client_secret,
            code: code
          },
          accept: :json
        ).and_return({ access_token: access_token }.to_json)

      get "/callback?code=#{code}"
      expect(session[:access_token]).to eql access_token
    end
  end

  describe 'GET /repos' do
    it 'redirects to root if access token is not present' do
      get '/repos'
      expect(last_response).to be_redirect
      expect(last_response.headers['Location']).to eql 'http://example.org/'
    end

    it 'fetches a list of all available repositories' do
      repolist = [{
        'id' => '47110815',
        'name' => 'streetcountdown',
        'full_name' => 'Absolventa/streetcountdown',
        'owner' => {
          'login' => 'Absolventa',
          'type' => 'Organization'
        },
        'private' => true,
        'description' => 'I have my long undergarments, so I should be ok',
        'collaborators_url' => 'oh yeah baby, right there!'
      }]
      expect_any_instance_of(GithubClient).
        to receive(:fetch).and_return(repolist)
      get '/repos', {}, { 'rack.session' => { 'access_token' => 'is present' } }
      expect(last_response).to be_ok
      expect(last_response.body).to match 'streetcountdown'
    end
  end

  describe 'GET /logout' do
    it 'clears the session and redirects to "/"' do
      get '/logout', {}, { 'rack.session' => { 'access_token' => 'is present' } }
      expect(session).to be_empty
      expect(last_response).to be_redirect
      expect(last_response.headers['Location']).to eql 'http://example.org/'
    end
  end

end
