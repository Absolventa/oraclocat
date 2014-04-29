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

      get "/orgs", {}, { 'rack.session' => { 'access_token' => 'is present' } }
      expect(last_response.body).to match 'Choose your organization'
    end
  end

  describe 'GET /orgs/:org' do
    it 'redirects to root if access token is not present' do
      get '/orgs/acme'
      expect(last_response).to be_redirect
      expect(last_response.headers['Location']).to eql 'http://example.org/'
    end

    context 'with valid access token' do
      before do
        orgs = [GH::Org.new(login: 'Acme'), GH::Org.new(login: 'Abslolventa')]
        expect_any_instance_of(GH::User).to receive(:orgs).
          and_return(orgs)
        allow_any_instance_of(GH::Client).to receive(:user).
          and_return GH::User.new(double(fetch: true))
      end

      it 'lists all issues of a given org' do
        stub_issues! [{
          'id' => 47110815,
          'title' => 'Play streetcountdown',
          'repository' => {
            'name' => 'streetcountdown',
            'full_name' => 'Absolventa/streetcountdown'
          },
          'assignee' => nil,
          'pull_request' => {
            'html_url' => 'https://example.com'
          }
        }]

        stub_collabs! [{ 'login' => 'moss' }]

        get '/orgs/Abslolventa', {}, { 'rack.session' => { 'access_token' => 'is present' } }
        expect(last_response).to be_ok
        expect(last_response.body).to match 'streetcountdown'
      end

      it 'does not list issues that are not pull requests' do
        stub_issues! [{
          'id' => 47110815,
          'title' => 'Play streetcountdown',
          'repository' => {
            'name' => 'streetcountdown',
            'full_name' => 'Absolventa/streetcountdown'
          },
          'assignee' => nil
        }]

        get '/orgs/Abslolventa', {}, { 'rack.session' => { 'access_token' => 'is present' } }
        expect(last_response).to be_ok
        expect(last_response.body).not_to match 'streetcountdown'
      end

      def stub_collabs!(collabslist)
        expect_any_instance_of(GH::Client).
          to receive(:fetch).
          with('https://api.github.com/repos/Abslolventa/streetcountdown/collaborators').
          and_return(collabslist)
      end

      def stub_issues!(issueslist)
        expect_any_instance_of(GH::Client).
          to receive(:fetch).
          with('https://api.github.com/orgs/Abslolventa/issues?filter=created&state=open').
          and_return(issueslist)
      end
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
