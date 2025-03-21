# app/models/job_assignment.rb
class JobAssignment < ApplicationRecord
    belongs_to :job
    belongs_to :subcontractor, class_name: 'User'
    belongs_to :assigned_by, class_name: 'User'
    
    validates :job_id, uniqueness: { scope: :subcontractor_id, message: "has already been assigned to this subcontractor" }
    
    # Validate that the subcontractor is indeed a subcontractor of the assigner
    validate :subcontractor_relationship
    
    private
    
    def subcontractor_relationship
      unless ContractorSubcontractor.exists?(contractor: assigned_by, subcontractor: subcontractor)
        errors.add(:subcontractor, "must be your subcontractor")
      end
    end
  end