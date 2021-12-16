class Api::RoomsController < Api::BaseController
  def show
    loc = Location.find_by!(floor_id: params[:location_id])
    users = loc.users.where(room: params[:id])
    render json: users, each_serializer: UserSummarySerializer, status: :ok
  end
end
