require 'rails_helper'

describe OrgUnitSummarySerializer do
  let(:org_unit) { create(:org_unit, :with_children) }

  describe '#children' do
    context 'without children_depth limit' do
      subject { described_class.new(org_unit).children.size }

      it { is_expected.to be 2 }
    end

    context 'with children_depth limit 0' do
      subject { described_class.new(org_unit, children_depth: 0).children.size }

      it { is_expected.to be 0 }
    end

    context 'with children_depth limit 1' do
      subject { described_class.new(org_unit, children_depth: 1).children.size }

      it { is_expected.to be 2 }
    end
  end
end
