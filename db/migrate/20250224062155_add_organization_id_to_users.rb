class AddOrganizationIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :organization, foreign_key: true, index: true # No null: false yet

  end
end
