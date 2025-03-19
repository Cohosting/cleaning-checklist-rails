# app/models/contractor_subcontractor.rb
class ContractorSubcontractor < ApplicationRecord
  belongs_to :contractor, class_name: 'User'
  belongs_to :subcontractor, class_name: 'User'
  
  validates :contractor_id, uniqueness: { scope: :subcontractor_id }
  validate :no_circular_reference
  validate :no_self_reference
  
  private
  
  def no_circular_reference
    # Basic implementation - can be enhanced to check deeper cycles
    if ContractorSubcontractor.exists?(contractor_id: subcontractor_id, subcontractor_id: contractor_id)
      errors.add(:base, "Creating this relationship would result in a circular reference")
    end
  end
  
  def no_self_reference
    if contractor_id == subcontractor_id
      errors.add(:base, "A user cannot be their own subcontractor")
    end
  end
end