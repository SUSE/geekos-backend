require 'rails_helper'

describe User do
  it { is_expected.to validate_uniqueness_of(:auth_token) }

  it_behaves_like 'fulltext searchable', :notes, :irc

  describe '#find' do
    let!(:user) { create(:user, :ldap) }

    context 'with username' do
      it 'finds its user' do
        expect(described_class.find(user.username)).not_to be_nil
      end

      it 'nil if not found' do
        expect(described_class.find('i_am_not_there')).to be_nil
      end
    end

    context 'with employeenumber' do
      it 'finds its user' do
        expect(described_class.find(user.employeenumber)).not_to be_nil
      end

      it 'nil if not found' do
        expect(described_class.find('123456')).to be_nil
      end
    end
  end
end
