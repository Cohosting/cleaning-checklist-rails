# class Job < ApplicationRecord
#   belongs_to :property
#   belongs_to :checklist, optional: true
#   has_many :job_tasks, dependent: :destroy

#   after_create :copy_tasks_from_checklist
#   before_create :generate_public_token

#   def completed_tasks
#     job_tasks.where(completed: true).count
#   end

#   def total_tasks
#     job_tasks.count
#   end

#   def status
#     return 'completed' if job_tasks.all?(&:completed?)
#     return 'in_progress' if job_tasks.any?(&:completed?)
#     'scheduled'
#   end

#   private

#   def generate_public_token
#     self.public_token = SecureRandom.hex(10) # Generates a 20-character token
#   end

#   def copy_tasks_from_checklist
#     return unless checklist
#     checklist.tasks.each do |task|
#       job_tasks.create!(name: task.name, completed: false)
#     end
#   end
# end
class Job < ApplicationRecord
  belongs_to :property
  belongs_to :checklist, optional: true
  
  has_many :job_sections, dependent: :destroy
  has_many :job_section_groups, through: :job_sections
  has_many :job_tasks, through: :job_section_groups
  
  validates :date, presence: true
  
  before_create :generate_public_token, unless: :public_token?

  def completion_percentage
    return 0 if job_tasks.empty?
    (job_tasks.where(completed: true).count.to_f / job_tasks.count * 100).round
  end
  
  def completed_tasks
    job_tasks.where(completed: true).count
  end


  def total_tasks 
    job_tasks.count
  end
  
  
  private
  
  def generate_public_token
    self.public_token = SecureRandom.hex(10)
  end
end
