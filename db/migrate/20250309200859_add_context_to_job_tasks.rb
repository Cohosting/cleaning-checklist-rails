class AddContextToJobTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :job_tasks, :content, :string
  end
end
