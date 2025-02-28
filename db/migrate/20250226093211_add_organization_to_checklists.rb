class AddOrganizationToChecklists < ActiveRecord::Migration[8.0]
  def change
    add_reference :checklists, :organization, null: false, foreign_key: true
  end
end
