class AddOrganizationToUpsells < ActiveRecord::Migration[8.0]
  def change
    add_reference :upsells, :organization, null: false, foreign_key: true
  end
end
