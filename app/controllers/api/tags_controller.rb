class Api::TagsController < Api::BaseController
  def index
    render json: Tag.all, status: :ok
  end

  def show
    render json: Tag.find_by(name: params[:id]), status: :ok
  end

  def search
    tags = Search.new(params[:q], Tag)
    render json: tags
  end
end
