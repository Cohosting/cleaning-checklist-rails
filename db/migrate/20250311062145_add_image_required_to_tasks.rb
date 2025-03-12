class AddImageRequiredToTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :image_required, :boolean, default: false
  end
end
