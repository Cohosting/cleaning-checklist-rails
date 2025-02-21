class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.string :platform
      t.string :platform_id
      t.references :guest, null: false, foreign_key: true
      t.datetime :booking_date
      t.datetime :arrival_date
      t.datetime :departure_date
      t.integer :nights
      t.datetime :check_in
      t.datetime :check_out
      t.string :status
      t.decimal :total_price
      t.string :currency

      t.timestamps
    end
    add_index :reservations, :platform_id, unique: true
  end
end
