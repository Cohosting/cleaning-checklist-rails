class CreateGuests < ActiveRecord::Migration[8.0]
  def change
    create_table :guests do |t|
      t.string :hospitable_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.json :phone_numbers

      t.timestamps
    end
    add_index :guests, :hospitable_id, unique: true
  end
end
