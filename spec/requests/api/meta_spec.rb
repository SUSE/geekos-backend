require 'rails_helper'

describe '/api/meta' do
  before do
    create_list(:user, 5, :ldap)
  end

  describe 'users' do
    subject(:users) { get(api_meta_users_path) }

    it 'returns the latest joined users' do
      users
      newcomers = response.parsed_body['newcomers']
      expect(newcomers.first['join_date']).to eq User.desc('suseid.date_joined').first.join_date.first(10)
      expect(newcomers.first['join_date']).to match(/\A201\d-\d\d-\d\d\z/)
    end
  end

  describe 'changes' do
    subject(:changes) { get(api_meta_changes_path) }

    before do
      Mongoid::AuditLog.record { User.last.update(notes: 'I am user') }
    end

    it 'returns latest changes' do
      changes
      changes = response.parsed_body['changes']
      expect(changes.first['changes']['notes'].last).to eq 'I am user'
    end
  end
end
