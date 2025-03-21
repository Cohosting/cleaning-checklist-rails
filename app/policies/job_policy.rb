# app/policies/job_policy.rb
class JobPolicy < ApplicationPolicy
  def index?
    # All users with access to the organization can see the jobs list
    user.member_of?(record.organization) || user.subcontractor_in?(record.organization)
  end
  
  def show?
    # Admin or regular member can see any job
    return true if user.member_of?(record.organization) && !user.contractor_in?(record.organization)
    
    # Contractor can see jobs assigned to them
    return true if record.assigned_to_id == user.id
    
    # Subcontractor can see jobs assigned to them by their contractors
    record.job_assignments.exists?(subcontractor: user)
  end
  
  def create?
    # Only members or admins can create jobs
    user.member_of?(record.organization) && !user.contractor_in?(record.organization)
  end
  
  def update?
    # Similar to show policy
    show?
  end
  
  def destroy?
    # Only admins can delete jobs
    user.role_in(record.organization) == 'admin'
  end
  
  class Scope < Scope
    def resolve
      # Start with the base scope
      result = scope
      
      # For organizations where user is a member
      if user.memberships.exists?
        member_orgs = user.memberships.pluck(:organization_id)
        
        # For contractors, only show jobs assigned to them
        contractor_orgs = user.memberships.where(role: 'contractor').pluck(:organization_id)
        
        # Build our query
        member_jobs = result.where(organization_id: member_orgs - contractor_orgs)
        contractor_jobs = result.where(organization_id: contractor_orgs, assigned_to_id: user.id)
        
        # Combine the two sets
        result = member_jobs.or(contractor_jobs)
      end
      
      # Add jobs where user is a subcontractor
      subcontractor_jobs = result.joins(:job_assignments).where(job_assignments: { subcontractor_id: user.id })
      
      # Return combined results, with duplicates removed
      # result = result.or(subcontractor_jobs).distinct
    end
  end
end