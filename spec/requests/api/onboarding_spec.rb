require 'rails_helper'

describe '/api/onboarding' do
  describe 'show' do
    subject(:onboarding) { get(api_onboarding_path) }

    it 'loads onboarding chapters' do
      allow(Onboarding).to receive(:chapters)
      expect(onboarding).to eq 200
    end
  end
end
