require 'rails_helper'

describe OrgUnit do
  describe '#depth_name' do
    subject { described_class.new(depth: depth).depth_name }

    context 'CEO' do
      let(:depth) { 0 }

      it { is_expected.to eq({ lead: 'CEO', unit: 'Company' }) }
    end

    context 'Org' do
      let(:depth) { 1 }

      it { is_expected.to eq({ lead: 'President', unit: 'Organization' }) }
    end

    context 'Group' do
      let(:depth) { 2 }

      it { is_expected.to eq({ lead: 'Vice President', unit: 'Group' }) }
    end

    context 'Department' do
      let(:depth) { 3 }

      it { is_expected.to eq({ lead: 'Department lead', unit: 'Department' }) }
    end

    context 'Team' do
      let(:depth) { 4 }

      it { is_expected.to eq({ lead: 'Teamlead', unit: 'Team' }) }
    end
  end

  describe '#lead' do
    subject(:org_unit) { described_class.new(lead: lead) }

    let(:lead) { create(:user) }

    it 'gets a lead by a workforceid' do
      expect(org_unit.lead).to eq lead
    end
  end

  describe '.types' do
    it 'contains values from DEPTH_NAMES' do
      expect(described_class.types).to match_array described_class::DEPTH_NAMES.values
    end
  end
end
