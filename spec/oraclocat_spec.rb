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
      expect(last_response).to be_redirect
      expect(last_response.headers['Location']).to eql 'http://example.org/orgs'
    end
  end

  describe 'GET /orgs' do
    it 'lets the user choose their org' do
      expect_any_instance_of(GH::User).to receive(:orgs).
        and_return([GH::Org.new, GH::Org.new])
      allow_any_instance_of(GH::Client).to receive(:user).
        and_return GH::User.new(double(fetch: true))

      get "/orgs"
      expect(last_response.body).to match 'Choose your organization'
    end
  end

  describe 'GET /orgs/:org' do
    it 'lists all repos of a given org' do
      orgs = [GH::Org.new(login: 'Acme'), GH::Org.new(login: 'Abslolventa')]
      expect_any_instance_of(GH::User).to receive(:orgs).
        and_return(orgs)
      allow_any_instance_of(GH::Client).to receive(:user).
        and_return GH::User.new(double(fetch: true))

      repolist = [{
        'id' => '47110815',
        'name' => 'streetcountdown',
        'full_name' => 'Absolventa/streetcountdown',
        'owner' => {
          'login' => 'Abslolventa',
          'type' => 'Organization'
        },
        'private' => true,
        'description' => 'I have my long undergarments, so I should be ok',
        'collaborators_url' => 'oh yeah baby, right there!'
      }]
      expect_any_instance_of(GH::Client).
        to receive(:fetch).
        with('https://api.github.com/orgs/Abslolventa/repos').
        and_return(repolist)

      get "/orgs/Abslolventa"
      expect(last_response).to be_ok
      expect(last_response.body).to match 'streetcountdown'
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
      expect_any_instance_of(GH::Client).
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
