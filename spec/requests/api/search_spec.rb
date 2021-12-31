require 'rails_helper'

describe '/api/search', type: 'request' do
  before do
    create_list(:user, 5)
    user = create(:user, :ldap)
    user.ldap.update(employeenumber: '23', title: 'Magic Mushroom')
    user.save
    [User, OrgUnit, Tag].each(&:create_indexes)
  end

  describe 'results from title' do
    before do
      get(api_search_path, params: { q: 'Mushroom' })
    end

    it 'gets exactly one result' do
      expect(json_response[:results].count).to eq 1
    end

    it 'conforms with defined structure' do
      expect(response).to match_response_schema('search/search')
    end
  end
end
