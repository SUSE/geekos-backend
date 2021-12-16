class Api::LocationsController < Api::BaseController
  def index
    render json: Location.all, status: :ok
  end

  def show
    loc = Location.find_by!(floor_id: params[:id])
    render json: loc.users, status: :ok
  end
end
