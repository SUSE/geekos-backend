RSpec.shared_examples 'search result' do |type_plural|
  describe 'wrapping' do
    before { create(described_class.name.underscore.to_sym) }

    it { is_expected.to match_response_schema("search/#{type_plural}_search") }
  end
end

RSpec.shared_examples 'fulltext searchable' do |attribute|
  describe '.search' do
    subject(:search_method) do
      described_class.match(string)
    end

    let(:string) { described_class.last.public_send(attribute) }

    before { create(described_class.name.underscore.to_sym) }

    its(:any?) { is_expected.to be true }

    it 'must have entries with the same attribute' do
      expect(search_method.pluck(attribute).first).to eq string
    end
  end
end
