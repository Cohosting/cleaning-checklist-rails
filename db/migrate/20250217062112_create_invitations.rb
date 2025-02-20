class CreateInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :invitations do |t|
      t.string :email, null: false
      t.string :token, null: false 
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
