require 'rails_helper'

describe '/api/tags' do
  before do
    create_list(:tag, 50)
  end

  describe 'root' do
    subject(:get_all) { get(api_tags_path) }

    it 'returns a list of tags' do
      get_all
      expect(response).to match_response_schema('tags')
    end
  end

  describe 'show' do
    subject(:get_one) { get(api_tag_path(Tag.last.name)) }

    it 'returns one tag requested by name' do
      get_one
      expect(response).to match_response_schema('tag')
    end
  end

  describe 'update' do
    subject do
      put(
        api_tag_path(id: tag.name),
        params: { description: 'foo' },
        headers:
      )
      json_response
    end

    let(:tag) { create(:tag) }
    let(:user) { create(:user) }
    let(:headers) do
      { 'Authorization' => "Token token=#{user.auth_token}" }
    end

    its(:description) { is_expected.to eq 'foo' }
  end

  describe 'search' do
    subject(:search_tag) { get(search_api_tags_path(q: Tag.last.name)) }

    it 'returns found tags in array' do
      search_tag
      expect(response).to match_response_schema('search/search_tags')
    end

    it 'returns empty array if nothing was found' do
      get(search_api_tags_path(q: 'NonExistentTag'))
      expect(json_response[:results]).to be_empty
    end
  end
end
