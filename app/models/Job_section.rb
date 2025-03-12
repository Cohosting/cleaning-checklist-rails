class JobSection < ApplicationRecord
  belongs_to :job
  has_many :job_section_groups, dependent: :destroy
  has_many :job_tasks, through: :job_section_groups
  
  validates :title, presence: true
  
  default_scope { order(position: :asc) }
end