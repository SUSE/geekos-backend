class Api::SearchesController < Api::BaseController
  def show
    render json: Search.new(search_params, [User, OrgUnit, Tag]), status: :ok
  end

  protected

  def search_params
    params.require(:q)
  end
end
