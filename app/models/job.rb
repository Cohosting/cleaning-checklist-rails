class Job < ApplicationRecord
  belongs_to :property
  belongs_to :checklist
  has_many :job_tasks, dependent: :destroy

  after_create :copy_tasks_from_checklist

  def completed_tasks
    job_tasks.where(completed: true).count
  end

  def total_tasks
    job_tasks.count
  end

  def status
    return 'completed' if job_tasks.all?(&:completed?)
    return 'in_progress' if job_tasks.any?(&:completed?)
    'scheduled'
  end

  private

  def copy_tasks_from_checklist
    checklist.tasks.each do |task|
      job_tasks.create!(name: task.name, completed: false)
    end
  end
end
