require 'spec_helper'

describe GH::Org do

  describe 'its constructor' do
    it 'sets its attributes from a hash' do
      subject = described_class.new org_attributes
      org_attributes.each do |attribute, value|
        expect(subject.public_send attribute).to eql value
      end
    end
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
