class AddContentToTask < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :content, :string
  end
end
