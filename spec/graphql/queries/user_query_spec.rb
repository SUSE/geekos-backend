require "rails_helper"

describe 'user query', type: 'request' do
  # current query used in the frontend
  let(:query) do
    <<~GQL
      query ($ident: String!) {
        user (ident: $ident) {
            fullname notes email orgUnit { id name }
            title picture (size: 100) phone leadOfOrgUnit { id name }
            tags { name } room coordinates location { id abbreviation city }
            opensuseUsername trelloUsername githubUsernames
            }
          }
    GQL
  end

  it 'returns user' do
    user = create(:user, :ldap, :okta, tags: [create(:tag)])
    post(graphql_path, params: { query: query, variables: { ident: user.username } }, headers: {})
    expect(json_response['data'].size).to eq 1
    expect(json_response['data']['user']).to include(
      email: user.email,
      title: user.title,
      tags: [{ "name" => user.tags.first.name }],
      coordinates: be_present
    )
  end
end
