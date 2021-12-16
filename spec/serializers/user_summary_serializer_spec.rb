require 'rails_helper'

describe UserSummarySerializer do
  let(:user) { create(:user, :ldap) }

  describe '#picture_160' do
    subject { described_class.new(user).picture_160 }

    context 'there is no img set on user' do
      it { is_expected.to be_nil }
    end

    context 'there is an img set on local_user' do
      before do
        user.img = File.read('spec/fixtures/dummy.png')
      end

      it { is_expected.to start_with '/media' }
    end
  end
end
