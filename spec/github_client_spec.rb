require 'spec_helper'

describe GithubClient do
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
      expect(RestClient).to receive(:post).
        with('https://github.com/login/oauth/access_token',
          {
            client_id: subject.client_id,
            client_secret: subject.client_secret,
            code: code
          },
          accept: :json
        ).and_return({ access_token: access_token }.to_json)
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

end
