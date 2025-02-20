class AddStatusToUpsell < ActiveRecord::Migration[8.0]
  def change
    add_column :upsells, :status, :string
  end
end
