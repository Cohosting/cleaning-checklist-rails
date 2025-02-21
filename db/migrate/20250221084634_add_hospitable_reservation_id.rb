class AddHospitableReservationId < ActiveRecord::Migration[8.0]
  def change
    add_column :reservations, :hospitable_reservation_id, :string
  end
end
