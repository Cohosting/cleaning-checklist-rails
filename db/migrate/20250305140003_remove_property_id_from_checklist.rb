class RemovePropertyIdFromChecklist < ActiveRecord::Migration[8.0]
  def change
    remove_reference :checklists, :property, null: false, foreign_key: true
  end
end
