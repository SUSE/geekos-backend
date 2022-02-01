require "rails_helper"

describe 'users query', type: 'request' do
  describe 'valid query' do
    let(:query) do
      <<~GQL
        query {
          users {
              username fullname notes email orgUnit { id name }
              title picture (size: 100) phone leadOfOrgUnit { id name }
              tags { name } room coordinates location { id abbreviation city }
              opensuseUsername trelloUsername githubUsernames
              }
            }
      GQL
    end

    it 'returns users' do
      create_list(:user, 3, :ldap, :okta)
      post(graphql_path, params: { query: query, variables: {}, headers: {} })
      expect(json_response['data']['users'].size).to eq 3
    end
  end

  describe 'invalid query' do
    let(:query) do
      <<~GQL
        query {
          users {
              attr
              }
            }
      GQL
    end

    it 'returns error' do
      create_list(:user, 3, :ldap, :okta)
      post(graphql_path, params: { query: query, variables: {}, headers: {} })
      expect(json_response.errors.first.message).to eq "Field 'attr' doesn't exist on type 'User'"
    end
  end
end
