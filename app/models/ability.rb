class Ability
  include CanCan::Ability

  def initialize(current_user)
    current_user ||= User.new
    can :manage, :all if current_user.admin
    can :read, :changes # if current_user.admin
    can :update, User, employeenumber: current_user.employeenumber
    can :update, OrgUnit do |org_unit|
      [current_user.org_unit, current_user.lead_of_org_unit].compact.include? org_unit
    end
    can :update, Tag unless current_user.new_record?
  end
end
