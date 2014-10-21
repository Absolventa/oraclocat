require 'spec_helper'

describe GH::Client do
  subject { described_class.new 'foo', 'bar' }

  describe 'its constructor' do
    it 'sets client data' do
      subject = described_class.new 'foo', 'bar'
      expect(subject.client_id).to eql 'foo'
      expect(subject.client_secret).to eql 'bar'
    end

    it 'sets token if desired' do
      subject = described_class.new nil, nil, 'baz'
      expect(subject.access_token).to eql 'baz'
    end
  end

  describe '#access_token=' do
    it 'sets a new token' do
      expect do
        subject.access_token = 'bloop'
      end.to change { subject.access_token }
    end
  end

  describe '#get_access_token!' do
    let(:code)         { "foobaz-#{rand(10000)}" }
    let(:access_token) { "foobar-#{rand(10000)}" }

    before do
      stub_github_access_token_endpoint!
    end

    it 'returns retrieved token' do
      expect(subject.get_access_token! code).to eql access_token
    end

    it 'sets access_token' do
      expect do
        subject.get_access_token! code
      end.to change { subject.access_token }
    end
  end

  describe '#fetch' do
    it 'makes the request without token' do
      url                  = 'http://oraclocat.local'
      subject.access_token = 'foobarbaz'
      stub_github_fetch!(url, client: subject) do
        { 'hello' => 'negative 1' }.to_json
      end

      result = subject.fetch(url)
      expect(result).to be_a Hash
    end
  end

  describe '#user' do
    it 'retuns nil if access_token is missing' do
      expect(subject.user).to be_nil
    end

    it 'fetches the user data and caches the return value' do
      expect_any_instance_of(GH::User).to receive(:fetch!)
      subject.access_token = 'fizzbuzz'
      expect(subject.user).to be_instance_of GH::User
    end
  end


end
