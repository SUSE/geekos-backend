require 'rails_helper'

describe Search do
  describe '.new' do
    context 'with multiple classes to search' do
      subject(:search) do
        described_class.new('George', [User, Tag])
      end

      let!(:user) { create(:user, :ldap, title: 'Master George') }
      let!(:tag) { create(:tag, name: 'Tag George') }

      before do
        User.create_indexes
        Tag.create_indexes
      end

      it 'has 2 hits' do
        expect(search.meta[:hits]).to eq 2
      end

      it 'has User + OrgUnit result' do
        expect(search.results).to eq [user, tag]
      end
    end

    context 'with one class to search' do
      subject(:search) do
        described_class.new('Master George', User)
      end

      let!(:user) { create(:user, :ldap, title: 'Master George') }

      before do
        User.create_indexes
      end

      it 'has 1 in hits in meta' do
        expect(search.meta[:hits]).to eq 1
      end

      it 'has results' do
        expect(search.results).to eq [user]
      end
    end

    context 'only searches in defined fields' do
      subject(:search) do
        described_class.new('Master George', User)
      end

      let!(:user) { create(:user, :ldap, title: 'Master George') }

      # let!(:user2) { create(:user, :ldap, auth_token: 'Master George') }

      before do
        User.create_indexes
        create(:user, :ldap, auth_token: 'Master George')
      end

      it 'only finds resultstring when in indexed field' do
        expect(search.results).to eq [user]
      end
    end

    context 'substrings (words)' do
      subject(:search) do
        described_class.new('George', User)
      end

      let!(:user) { create(:user, :ldap, title: 'Master George') }

      before do
        User.create_indexes
      end

      it 'finds result with substring' do
        expect(search.results).to eq [user]
      end
    end

    context 'case insensitive' do
      subject(:search) do
        described_class.new('george', User)
      end

      let!(:user) { create(:user, :ldap, title: 'Master George') }

      before do
        User.create_indexes
      end

      it 'finds result with lowercase query' do
        expect(search.results).to eq [user]
      end
    end
  end
end
