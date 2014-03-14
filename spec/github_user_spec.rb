require 'spec_helper'

describe GH::User do

  let(:connector) { double('Connector', fetch: true) }
  subject { described_class.new connector }

  describe 'its constructor' do
    it 'requires argument to respond to :fetch' do
      expect do
        described_class.new Object.new
      end.to raise_error ArgumentError
    end

    it 'sets the api connector' do
      api_connector = connector
      subject = described_class.new api_connector
      expect(subject.connector).to eql api_connector
    end
  end

  context 'with attributes' do
    %w(avatar_url email login name).each do |attribute|
      it "responds to #{attribute}" do
        expect(subject.public_send attribute).to be_nil
      end
    end
  end

  describe '.endpoint' do
    it 'defines the REST endpoint' do
      expect(described_class.endpoint).
        to eql 'https://api.github.com/user'
    end

    it { expect(described_class.endpoint).to be_frozen }
  end

  describe '#fetch!' do
    it 'pulls the user data from the API' do
      stub_gh_client_fetch! api_response

      subject.fetch!

      api_response.each do |key, value|
        expect(subject.public_send key).to eql value
      end
    end
  end

  describe '#orgs' do
    before do
      orglist = [ org_attributes, org_attributes ]
      stub_gh_client_fetch! orglist, "#{described_class.endpoint}/orgs"
    end

    it 'returns a list of GH::Org instances' do
      subject.orgs.each do |org|
        expect(org).to be_instance_of GH::Org
      end
    end

    it 'caches the fetched result' do
      subject.orgs
      subject.orgs
    end
  end

  def stub_gh_client_fetch!(data = nil, endpoint = nil)
    data ||= api_response
    endpoint ||= described_class.endpoint
    expect(subject.connector).to receive(:fetch).
      with(endpoint).and_return(data).once
  end

  def api_response
    {
      'avatar_url' => 'https://github.com/images/error/octocat_happy.gif',
      'email'      => 'octocat@github.com',
      'login'      => 'octocat',
      'name'       => 'monalisa octocat'
    }
  end

  def org_attributes
    @attributes ||= {
      'login'              => 'Absolventa',
      'id'                 => rand(999999),
      'url'                => 'https://api.github.com/orgs/Absolventa',
      'repos_url'          => 'https://api.github.com/orgs/Absolventa/repos',
      'events_url'         => 'https://api.github.com/orgs/Absolventa/events',
      'members_url'        => 'https://api.github.com/orgs/Absolventa/members{/member}',
      'public_members_url' => 'https://api.github.com/orgs/Absolventa/public_members{/member}',
      'avatar_url'         => 'https://github.com/images/error/octocat_happy.gif'
    }
  end

end
