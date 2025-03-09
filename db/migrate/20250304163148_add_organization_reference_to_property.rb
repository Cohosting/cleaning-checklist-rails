class AddOrganizationReferenceToProperty < ActiveRecord::Migration[8.0]
  def change
    add_reference :properties, :organization, null: false, foreign_key: true
  end
end
