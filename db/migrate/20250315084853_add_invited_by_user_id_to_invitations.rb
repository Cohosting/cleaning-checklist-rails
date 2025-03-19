class AddInvitedByUserIdToInvitations < ActiveRecord::Migration[8.0]
  def change
    add_column :invitations, :invited_by_user_id, :integer
    add_index :invitations, :invited_by_user_id
  end
end
