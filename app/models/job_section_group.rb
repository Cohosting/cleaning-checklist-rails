# app/models/job_section_group.rb
class JobSectionGroup < ApplicationRecord
  belongs_to :job_section
  belongs_to :group
  has_many :job_tasks, dependent: :destroy
  
  validates :position, presence: true
  
  default_scope { order(position: :asc) }
end
