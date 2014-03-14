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

  def stub_gh_client_fetch!(data = nil)
    data ||= api_response
    expect(subject.connector).to receive(:fetch).
      with(described_class.endpoint).and_return(data)
  end

  def api_response
    {
      'avatar_url' => 'https://github.com/images/error/octocat_happy.gif',
      'email'      => 'octocat@github.com',
      'login'      => 'octocat',
      'name'       => 'monalisa octocat'
    }
  end

end
