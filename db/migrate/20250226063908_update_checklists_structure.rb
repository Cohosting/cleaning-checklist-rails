class UpdateChecklistsStructure < ActiveRecord::Migration[8.0]
  def change
    remove_reference :checklists, :property, index: true, foreign_key: true
    add_column :checklists, :title, :string, null: false
    add_column :checklists, :description, :text
    change_column_null :checklists, :name, true
  end
end
