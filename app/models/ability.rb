class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    can :manage, :all if user.admin
    can :update, User, employeenumber: user.employeenumber
    can :update, OrgUnit do |org_unit|
      [user.org_unit, user.lead_of_org_unit].compact.include? org_unit
    end
  end
end
