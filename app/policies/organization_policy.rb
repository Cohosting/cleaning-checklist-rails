# app/policies/organization_policy.rb
class OrganizationPolicy < ApplicationPolicy
  def show?
    user.member_of?(record) || user.subcontractor_in?(record)
  end
  
  def create?
    true
  end
  
  def update?
    user.role_in(record) == 'admin'
  end
  
  def destroy?
    user.role_in(record) == 'admin'
  end
  
  class Scope < Scope
    def resolve
      # Get organizations the user is a direct member of
      member_orgs = scope.joins(:memberships).where(memberships: { user_id: user.id })
      
      # Add subcontractor organizations if needed
      if user.subcontractor_relationships.exists?
        # Get contractors
        contractor_ids = ContractorSubcontractor
          .where(subcontractor_id: user.id)
          .pluck(:contractor_id)
        
        # Get their organizations
        subcontractor_orgs = scope.joins(:memberships)
          .where(memberships: { user_id: contractor_ids, role: 'contractor' })
        
        # Combine without duplicates
        return member_orgs.or(subcontractor_orgs).distinct
      end
      
      member_orgs
    end
  end
end