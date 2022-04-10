require "rails_helper"

describe 'user mutation', type: 'request' do
  # current update query used in the frontend
  let(:query) do
    <<~GQL
      mutation ($ident: String!, $title: String, $notes: String, $coordinates: String,
                        $locationId: Int, $tags: String, $avatar: String, $phone: String,
                        $room: String, $opensuseUsername: String) {
          updateUser (ident: $ident, title: $title, notes: $notes, coordinates: $coordinates,
                      locationId: $locationId, tags: $tags, avatar: $avatar, phone: $phone,
                      room: $room, opensuseUsername: $opensuseUsername) {
              username fullname notes email orgUnit { id name }
              title picture_160: picture (size: 160) picture_50: picture (size: 50)
              phone leadOfOrgUnit { id name } tags { name } room coordinates
              location { id abbreviation city address country }
              opensuseUsername trelloUsername githubUsernames
              }
          }
    GQL
  end

  context 'with authentication' do
    it 'updates user attributes' do
      user = create(:user, :ldap, :okta, tags: [create(:tag)])
      post(graphql_path, params: { query:,
                                   variables: { ident: user.username, title: 'mc', notes: "it's me" } },
                         headers: { Authorization: "Token token=#{user.auth_token}" })
      expect(user.reload.title).to eq 'mc'
    end

    it 'updates user avatar' do
      user = create(:user, :ldap, :okta, tags: [create(:tag)])
      # base64 encoded pixel
      b64_img = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=='
      post(graphql_path, params: { query:,
                                   variables: { ident: user.username, avatar: b64_img } },
                         headers: { Authorization: "Token token=#{user.auth_token}" })
      expect(user.reload.img_uid).to be_present
    end
  end

  context 'without authentication' do
    it 'requests authentication' do
      user = create(:user, :ldap, :okta, tags: [create(:tag)])
      post(graphql_path, params: { query:, variables: { ident: user.username } }, headers: {})
      expect(json_response.errors.first.first.last).to eq 'Please authenticate with token'
    end
  end

  context 'when authenticated as another user' do
    it 'requests authentication' do
      user = create(:user, :ldap, :okta, tags: [create(:tag)])
      user2 = create(:user, :ldap, :okta, tags: [create(:tag)])
      post(graphql_path, params: { query:, variables: { ident: user.username } },
                         headers: { Authorization: "Token token=#{user2.auth_token}" })
      expect(json_response.errors.first.first.last).to eq 'You can only update your own user.'
    end
  end
end
