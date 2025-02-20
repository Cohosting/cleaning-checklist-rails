class JobTask < ApplicationRecord
  has_many_attached :images 
  belongs_to :job

  validates :name, presence: true

  after_commit :broadcast_job_tasks_list, on: [:create, :update, :destroy]

 private 
  def broadcast_job_tasks_list
    broadcast_replace_to     "job_#{job.id}_tasks",
     target: "job_tasks",  
     partial: "job_shares/job_tasks",
     locals: { job: job }
  end
end
