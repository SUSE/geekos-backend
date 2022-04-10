require 'rails_helper'

describe Crawler::Ldap do
  before do
    allow(Ldap).to receive_message_chain(:active_users, :select).and_return(fake_users)
    allow(Crawler::Okta).to receive_message_chain(:new, :okta_users).and_return([])
    allow(fake_users).to receive(:select!).and_return(fake_users)
  end

  describe '#run' do
    subject(:ldap_crawler) { described_class.new }

    let(:user) { create(:user, :ldap) }
    let(:new_user) do
      { 'samaccountname' => 'u1', 'displayname' => 'u1',
        'mail' => '1@suse.com', 'employeenumber' => '1',
        'manager' => 'CN=Mr Manager,OU=User accounts,DC=corp,DC=suse,DC=com',
        'telephonenumber' => '+49 1', 'title' => 'Job 1', 'company' => 'SUSE' }
    end
    let(:existing_user) do
      { 'samaccountname' => 'u2', 'displayname' => 'u2', 'cn' => 'Mr Manager',
        'mail' => '2@suse.com', 'employeenumber' => user.employeenumber,
        'telephonenumber' => '+49 2', 'title' => 'Job 2', 'company' => 'SUSE' }
    end
    let(:fake_users) { [new_user, existing_user] }

    it 'imports all of the users from ldap' do
      expect { ldap_crawler.run }.to change(User, :count).from(1).to(2)
    end

    it 'updates_existing records' do
      expect { ldap_crawler.run }.to change { user.reload.updated_at }
    end

    it 'sets manager' do
      ldap_crawler.run
      expect(User.find('u1').manager).to eq user
    end

    it 'cleans up users no more found in ldap' do
      gone_user = create(:user)

      ldap_crawler.run
      expect(User.find_by(id: gone_user.id)).to be_nil
    end
  end
end
