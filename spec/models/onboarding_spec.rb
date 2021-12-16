require 'rails_helper'

ENV['geekos_trello_lists'] = 'test'

describe Onboarding do
  describe '.chapters' do
    it 'uses the list ids to query Trello' do
      allow(Trello::List).to receive(:find).and_return instance_double('Trello::List', name: 'test list', cards: [])
      described_class.chapters
    end
  end
end
