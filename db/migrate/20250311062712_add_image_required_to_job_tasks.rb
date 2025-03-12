class AddImageRequiredToJobTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :job_tasks, :image_required, :boolean, default: false

  end
end
