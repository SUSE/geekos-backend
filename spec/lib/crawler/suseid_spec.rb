require 'rails_helper'

describe Crawler::Suseid do
  subject(:suseid_crawler) { described_class.new }

  # one result of https://id.suse.com/api/v3/core/users/
  def api_user(username, employee_number, email: nil, github: nil)
    { 'username' => username,
      'email' => email || "#{username}@suse.com",
      'name' => "Mr #{username}",
      'uuid' => 'authentik-own-uuid',
      'date_joined' => '2026-02-10T16:33:10.634626Z',
      'attributes' => {
        'uuid' => "ldap-uuid-#{username}",
        'title' => "Job #{employee_number}",
        'office' => 'DENUE - Nuremberg',
        'division' => 'Engineering',
        'department' => 'Global Sales',
        'costCenter' => '110488889',
        'workLocationType' => 'Home-Based',
        'employeeNumber' => employee_number,
        'telephoneNumber' => "+49 #{employee_number}",
        'address' => { 'country' => 'DE' },
        'managerUid' => 'boss',
        'socialId' => github ? { 'GitHub' => github } : {}
      } }
  end

  let(:user) { create(:user, :ldap) }
  let(:api_users) { [api_user('u1', '00000002', email: user.email, github: 'gh_1')] }

  before do
    stub_const("#{described_class}::TOKEN", 'test')
    allow(RestClient).to receive(:get).with(String, Hash).and_return(
      instance_double(RestClient::Response,
                      body: { 'pagination' => { 'total_pages' => 1 }, 'results' => api_users }.to_json)
    )
  end

  describe '#run' do
    it 'stores the attributes on an existing user' do
      suseid_crawler.run
      expect(user.reload.suseid).to eq(
        'username' => 'u1', 'email' => user.email, 'name' => 'Mr u1', 'uuid' => 'ldap-uuid-u1',
        'date_joined' => '2026-02-10T16:33:10.634626Z', 'title' => 'Job 00000002',
        'office' => 'DENUE - Nuremberg', 'division' => 'Engineering', 'department' => 'Global Sales',
        'costCenter' => '110488889', 'workLocationType' => 'Home-Based', 'employeeNumber' => '00000002',
        'telephoneNumber' => '+49 00000002', 'country' => 'DE', 'managerUid' => 'boss',
        'githubUsername' => ['gh_1']
      )
    end

    it 'leaves the ldap and okta attributes alone' do
      expect { suseid_crawler.run }.not_to(change { user.reload.attributes.slice('ldap', 'okta') })
    end

    context 'when the suse id user has no record in the db' do
      let(:api_users) { [api_user('nobody', '00000003')] }

      it 'does not create the user' do
        user
        expect { suseid_crawler.run }.not_to change(User, :count)
      end
    end

    it 'does not delete users that are unknown in suse id' do
      gone_user = create(:user, :ldap)

      suseid_crawler.run
      expect(User.find_by(id: gone_user.id)).to eq gone_user
    end

    it 'raises without a token' do
      stub_const("#{described_class}::TOKEN", nil)
      expect { suseid_crawler.run }.to raise_error(/geekos_suseid_token/)
    end
  end

  describe '#users' do
    let(:api_users) { [api_user('u2', '00000003'), api_user('u1', '00000002')] }

    it 'sorts by username' do
      expect(suseid_crawler.users.pluck('username')).to eq %w[u1 u2]
    end

    # a bracketed list is dropped by django-filter, which returns every user
    it 'asks for the employee groups with repeated keys' do
      suseid_crawler.users
      expect(RestClient).to have_received(:get).with(
        %r{/api/v3/core/users/\?groups_by_name=employees&groups_by_name=contingent-workers&}, anything
      )
    end
  end

  describe '#user_by_email' do
    it 'filters server side instead of paging through everybody' do
      expect(suseid_crawler.user_by_email('u1@suse.com')).to include('username' => 'u1')
      expect(RestClient).to have_received(:get).with(/&email=u1%40suse\.com\z/, anything).once
    end

    context 'when the email is unknown' do
      let(:api_users) { [] }

      it { expect(suseid_crawler.user_by_email('nobody@suse.com')).to be_nil }
    end
  end
end
