class RemoveOrganizationIdFromUsers < ActiveRecord::Migration[8.0]
  def change
    if column_exists?(:users, :organization_id)
      remove_reference :users, :organization, foreign_key: true, index: true
    end
  end
end
