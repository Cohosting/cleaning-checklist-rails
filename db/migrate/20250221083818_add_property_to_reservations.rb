class AddPropertyToReservations < ActiveRecord::Migration[8.0]
  def change
    add_reference :reservations, :property,  foreign_key: true
  end
end
