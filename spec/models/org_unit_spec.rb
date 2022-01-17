require 'rails_helper'

describe OrgUnit do
  describe '#lead' do
    subject(:org_unit) { described_class.new(lead: lead) }

    let(:lead) { create(:user) }

    it 'gets a lead by a workforceid' do
      expect(org_unit.lead).to eq lead
    end
  end
end
