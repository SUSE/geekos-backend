require 'rails_helper'

describe User, type: 'request' do
  before do
    create_list(:user, 5, :ldap)
    described_class.create_indexes
  end

  describe 'get a user by employeenumber' do
    subject(:get_one_user_request) do
      get api_user_path(described_class.last.employeenumber)
      response
    end

    it { is_expected.to match_response_schema('user') }

    it 'has 200 return status' do
      expect(get_one_user_request.code.to_i).to eq 200
    end

    context 'non-found workforceid' do
      subject(:get_one_user_with_wrong_id) do
        get api_user_path('wrongid')
        response
      end

      it 'has 404 status when nothing is found' do
        expect(get_one_user_with_wrong_id.code.to_i).to eq 404
      end

      it 'returns arrays of errors' do
        get_one_user_with_wrong_id
        expect(json_response[:errors]).to match_array ['user not found']
      end
    end
  end

  describe 'search for a user' do
    subject(:search_for_a_user_request) do
      get(search_api_users_path(q: 'Hero'))
      response
    end

    before { described_class.last.update(title: 'Hero') }

    context 'with results' do
      it_behaves_like 'search result', 'users'

      it 'has one result' do
        search_for_a_user_request
        expect(json_response[:results].size).to be > 0
      end
    end

    context 'with no result' do
      subject(:search_with_no_results) do
        get(search_api_users_path(q: 'SauronTheWhite'))
        response
      end

      it_behaves_like 'search result', 'users'

      it 'has no result' do
        search_with_no_results
        expect(json_response[:results].size).to be 0
      end
    end
  end

  describe 'update tags for the user' do
    let(:user) { described_class.last }
    let(:headers) do
      { 'Authorization' => "Token token=#{user.auth_token}" }
    end

    context 'add new tags' do
      subject(:tag) do
        patch(
          api_user_path(user.employeenumber),
          params: { tags: %w[foo bar baz] },
          headers:
        )
        json_response
      end

      before do
        user.tags << Tag.create(name: 'foo')
        user.tags << Tag.create(name: 'bar')
        Tag.create(name: 'baz')
      end

      it 'adds tags to the user' do
        tag
        expect(json_response.tags.size).to eq 3
      end
    end

    context 'removes all tags' do
      subject(:tag) do
        patch(
          api_user_path(user.employeenumber),
          params: {},
          headers:
        )
        json_response
      end

      before do
        user.tags << Tag.create(name: 'foo')
        user.tags << Tag.create(name: 'bar')
        user.tags << Tag.create(name: 'baz')
      end

      it 'removes tags from the user' do
        tag
        expect(json_response.tags.size).to eq 0
      end
    end
  end

  describe 'update a user' do
    before do
      user.update!(phone: 6196)
    end

    context 'valid payload' do
      subject(:update_user_request) do
        patch(api_user_path(user.employeenumber), params: { phone: '6296' }, headers:)
        response
      end

      let(:user) { described_class.last }
      let(:headers) do
        { 'Authorization' => "Token #{user.auth_token}" }
      end

      it 'changes phone number' do
        expect { update_user_request }.to change { user.reload.phone }.to('6296')
      end

      context 'avatar upload' do
        subject(:update_user_request) do
          patch(api_user_path(user.employeenumber), params: { avatar: avatar_file }, headers:)
          response
        end

        let(:avatar_file) { Rack::Test::UploadedFile.new(File.open(Rails.root.join('spec/fixtures/avatar.png'))) }

        it 'updates avatar' do
          expect { update_user_request }.to change { user.reload.img_uid }
        end
      end
    end

    context 'invalid payload' do
      subject(:update_user_request) do
        patch(api_user_path(user.employeenumber), params: { coordinates: 123 }, headers:)
        response
      end

      let(:user) { described_class.last }
      let(:headers) do
        { 'Authorization' => "Token #{user.auth_token}" }
      end

      it 'has 422 status' do
        expect(update_user_request.status.to_i).to eq 422
      end

      it 'responds with error' do
        update_user_request
        expect(json_response).to have_key :errors
      end
    end
  end

  describe 'verify user token' do
    subject(:valid_token_request) do
      get(verify_token_api_users_path(auth_token: described_class.last.auth_token))
      response
    end

    context 'with valid token' do
      it { is_expected.to match_response_schema('user') }

      it 'has 200 return status' do
        expect(valid_token_request.code.to_i).to eq 200
      end
    end

    context 'with invalid token' do
      subject(:invalid_token_request) do
        get(verify_token_api_users_path(auth_token: 'invalid'))
        response
      end

      it 'has 404 status' do
        expect(invalid_token_request.code.to_i).to eq 404
      end

      it 'has one result' do
        invalid_token_request
        expect(json_response[:user]).to be_nil
      end
    end
  end
end
