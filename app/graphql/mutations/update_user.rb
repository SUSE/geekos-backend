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
  argument :avatar, String, required: false

  type Types::UserType

  def resolve(ident:, **attributes)
    user = user(ident)
    if attributes[:avatar]
      user.img = Base64.decode64(attributes[:avatar])
      user.img.name = "upload.#{user.employeenumber}.#{user.img.format}"
    end
    user.update(mass_assign_attributes(attributes))
    user.update(tags: tags_attributes(attributes).map { |t| Tag.find_or_create_by(name: t) })
    user.save!
    user
  end

  def authorized?(ident:, **_attributes)
    raise GraphQL::ExecutionError, "Please authenticate with token" unless context[:current_user]
    return true if Ability.new(context[:current_user]).can?(:update, user(ident))

    raise GraphQL::ExecutionError, "You can only update your own user."
  end

  private

  def mass_assign_attributes(attributes)
    # drop nil values, set empty values to nil for value reset
    exclude = %i[tags avatar]
    attributes.except(*exclude)
              .compact.transform_values(&:presence)
  end

  def tags_attributes(attributes)
    attributes[:tags].to_s.split(',').map { |t| t.strip.downcase }.compact_blank
  end

  def user(ident)
    @user ||= User.find(ident)
  end
end
