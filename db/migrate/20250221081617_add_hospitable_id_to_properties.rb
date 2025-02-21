class AddHospitableIdToProperties < ActiveRecord::Migration[8.0]
  def change
    add_column :properties, :hospitable_id, :string
    add_index :properties, :hospitable_id, unique: true
  end
end
