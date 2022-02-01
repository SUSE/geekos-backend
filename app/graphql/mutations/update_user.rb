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
  argument :tags, String, required: false
  # TODO: avatar

  type Types::UserType

  def resolve(ident:, **attributes)
    user = user(ident)
    user.update!(mass_assign_attributes(attributes))
    user.update(tags: tags_attributes(attributes).map { |t| Tag.find_or_create_by(name: t) })
    user
  end

  def authorized?(ident:, **_attributes)
    raise GraphQL::ExecutionError, "Please authenticate with token" unless context[:current_user]
    return true if Ability.new(context[:current_user]).can?(:update, user(ident))

    raise GraphQL::ExecutionError, "You can only update your own user."
  end

  private

  def mass_assign_attributes(attributes)
    attributes.reject{|k, _v| [:tags].include? k}.reject{|_k, v| v.blank?}
  end

  def tags_attributes(attributes)
    attributes[:tags].to_s.split(',').map(&:strip).map(&:downcase).compact_blank
  end

  def user(ident)
    @user ||= User.find(ident)
  end
end
