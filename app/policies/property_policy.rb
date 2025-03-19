# app/policies/property_policy.rb
class PropertyPolicy < ApplicationPolicy
  def show?
    # Only members and admins, not contractors or subcontractors
    user.member_of?(record.organization) && 
      !user.contractor_in?(record.organization)
  end

  def create?
    # Only members and admins, not contractors or subcontractors
    user.member_of?(record.organization) && 
      !user.contractor_in?(record.organization)
  end

  def update?
    # Only members and admins, not contractors or subcontractors
    user.member_of?(record.organization) && 
      !user.contractor_in?(record.organization)
  end

  def destroy?
    # Only admins can delete
    user.role_in(record.organization) == 'admin'
  end

  class Scope < Scope
    def resolve
      # If not a member, return nothing
      return scope.none unless user.memberships.exists?

      # Get organizations where user is a member but not a contractor
      regular_member_orgs = user.memberships
        .where.not(role: 'contractor')
        .pluck(:organization_id)
      
      # Return properties in those organizations
      scope.where(organization_id: regular_member_orgs)
    end
  end
end