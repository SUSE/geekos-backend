class Mutations::UpdateUser < Mutations::BaseMutation
  include CanCan::Ability

  # arguments passed to the `resolve` method
  argument :ident, String, required: true
  argument :opensuse_username, String, required: false
  argument :birthday, String, required: false
  argument :room, String, required: false
  argument :coordinates, String, required: false
  argument :notes, String, required: false
  argument :title, String, required: false
  argument :phone, String, required: false
  argument :location_id, Integer, required: false
  # TODO: avatar, tags

  type Types::UserType

  def resolve(ident:, **attributes)
    user = user(ident)
    user.update!(attributes)
    user
  end

  def authorized?(ident:, **_attributes)
    raise GraphQL::ExecutionError, "Please authenticate" unless context[:current_user]
    return true if Ability.new(context[:current_user]).can?(:update, user(ident))

    raise GraphQL::ExecutionError, "You can only update your own user."
  end

  private

  def user(ident)
    @user ||= User.find(ident)
  end
end
