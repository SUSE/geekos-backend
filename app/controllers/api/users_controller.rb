class Api::UsersController < Api::BaseController
  def show
    user = User.find(params[:id])
    if user
      render json: user, status: :ok
    else
      render json: { errors: ['user not found'] }, status: :not_found
    end
  end

  def update
    user = User.find(params[:id])
    authorize! :update, user
    if params[:avatar]
      user.img = params[:avatar].read
      user.img.name = "upload.#{user.employeenumber}.#{user.img.format}"
    end
    # TODO: update params[:location]
    if user.update(user_params)
      render json: user
    else
      render json: { errors: user.errors }, status: :unprocessable_entity
    end
  end

  def tags
    user = User.find(params[:id])
    authorize! :update, user
    tags = Tag.in(name: tags_params)
    user.tags = tags
    user.save
    render json: user
  end

  def search
    render json: Search.new(search_params, [User]), serializer: UserSearchSerializer, status: :ok
  end

  def verify_token
    user = User.find_by(auth_token: params[:auth_token])
    if user
      render json: user, status: :ok
    else
      render json: { user: nil }, status: :not_found
    end
  end

  private

  def search_params
    params.require(:q)
  end

  # user
  def user_params
    params[:location] = params[:location].to_i
    params.permit(
      :birthday,
      :img,
      :room,
      :coordinates,
      :location,
      :notes,
      :title,
      :phone
    )
  end

  def tags_params
    params.permit(tags: [])[:tags]
  end
end
