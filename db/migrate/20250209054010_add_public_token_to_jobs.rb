class AddPublicTokenToJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :jobs, :public_token, :string
    add_index :jobs, :public_token
  end
end
