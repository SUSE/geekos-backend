require 'rails_helper'

describe 'Teams endpoint' do
  before do
    orgs = create_list(:org_unit, 3)
    OrgUnit.create_indexes
  end

  describe 'root' do
    subject do
      get(root_api_teams_path)
      response
    end

    before { allow_any_instance_of(Crawler::OrgTree).to receive(:root).and_return(OrgUnit.first.lead) }

    it { is_expected.to match_response_schema('org_unit_summary') }
  end

  describe 'search' do
    subject do
      get(search_api_teams_path(q: OrgUnit.first.name))
      response
    end

    it { is_expected.to match_response_schema('search/search_teams') }
  end

  describe 'index' do
    subject do
      get(api_teams_path)
      response
    end

    it { is_expected.to match_response_schema('org_units') }
  end

  describe 'update' do
    subject do
      put(
        api_team_path(team),
        params: new_team_data,
        headers:
      )
      json_response
    end

    let(:team) { OrgUnit.last }
    let(:user) { team.members.last }
    let(:headers) do
      { 'Authorization' => "Token token=#{user.auth_token}" }
    end
    let(:new_team_data) do
      {
        name: 'new world order',
        short_description: 'foo',
        description: 'bar'
      }
    end

    before do
      org = create(:org_unit)
      org.members << User.last
    end

    its(:name) { is_expected.to eq 'new world order' }
    its(:short_description) { is_expected.to eq 'foo' }
    its(:description) { is_expected.to eq 'bar' }
  end

  describe 'show' do
    subject do
      get(api_team_path(OrgUnit.last.id))
      response
    end

    describe 'without parents' do
      before do
        create(:org_unit)
      end

      it { is_expected.to match_response_schema('org_unit') }
    end

    describe 'with parents' do
      before do
        create(:org_unit, parent: create(:org_unit))
      end

      it { is_expected.to match_response_schema('org_unit') }
    end

    describe 'with a wrong id' do
      it 'returns 404 for non-existent teams' do
        get(api_team_path('foobarbaz'))
        expect(response.code).to eq '404'
      end
    end
  end
end
