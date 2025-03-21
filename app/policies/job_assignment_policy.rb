# app/policies/job_assignment_policy.rb
class JobAssignmentPolicy < ApplicationPolicy
  def create?
    # Must be a contractor
    return false unless user.contractor?
    
    # Must be assigned to the job being assigned
    return false unless record.job.assigned_to_id == user.id
    
    # Must be the contractor for the subcontractor being assigned
    ContractorSubcontractor.exists?(
      contractor: user, 
      subcontractor: record.subcontractor
    )
  end
  
  def destroy?
    # Only the contractor who created the assignment can remove it
    record.assigned_by_id == user.id
  end
  
  class Scope < Scope
    def resolve
      # For contractors, show assignments they created
      if user.contractor?
        return scope.where(assigned_by_id: user.id)
      end
      
      # For others, show none
      scope.none
    end
  end
end