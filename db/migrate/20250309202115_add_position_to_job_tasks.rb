class AddPositionToJobTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :job_tasks, :position, :integer, default: 0
  end
end
