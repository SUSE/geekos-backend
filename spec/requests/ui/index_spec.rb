require 'rails_helper'

describe '/' do
  describe 'index' do
    subject(:index) { get(root_path) }

    it 'returns api docs' do
      index
      expect(response.body).to match(/API/)
    end
  end
end
