class Api::TeamsController < Api::BaseController
  def index
    render json: OrgUnit.all, status: :ok
  end

  def root
    root_team = Crawler::OrgTree.new.root.lead_of_org_unit
    render json: root_team, serializer: OrgUnitSummarySerializer, status: :ok
  end

  def show
    team = OrgUnit.find(params[:id])
    if team
      render json: team, status: :ok
    else
      render json: { errors: ['team not found'] }, status: :not_found
    end
  end

  def update
    team = OrgUnit.find(params[:id])
    authorize! :update, team
    team.update!(name: team_params[:name], short_description: team_params[:short_description],
                 description: team_params[:description])
    # TODO: update tags
    render json: team
  end

  def search
    teams = Search.new(params[:q], [OrgUnit])
    render json: teams
  end

  protected

  def team_params
    params.permit(:name, :short_description, :description, :tags)
  end
end
