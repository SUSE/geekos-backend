require 'rails_helper'

describe Crawler::Okta do
  before do
    allow_any_instance_of(Oktakit::Client).to receive(:list_users).and_return(okta_users)
  end

  describe '#run' do
    subject(:okta_crawler) { described_class.new }

    let(:user) { create(:user, :ldap) }
    let(:okta_users) do
      [[OpenStruct.new({ status: 'ACTIVE', profile: OpenStruct.new({ githubUsername: ["gh_1"],
                                                                     trelloId: "trello_1", email: user.email }) }),
        OpenStruct.new({ status: 'ACTIVE', profile: OpenStruct.new({ email: 'not_there' }) })], 200]
    end

    it 'updates existing users' do
      expect { okta_crawler.run }.to change { user.reload.updated_at }
    end

    it 'updates trello username' do
      expect { okta_crawler.run }.to change { user.reload.trello_username }
    end

    it 'updates gh usernames' do
      expect { okta_crawler.run }.to change { user.reload.github_usernames }
    end
  end
end
