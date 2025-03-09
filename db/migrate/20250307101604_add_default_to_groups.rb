class AddDefaultToGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :groups, :default, :boolean, default: false
  end
end
