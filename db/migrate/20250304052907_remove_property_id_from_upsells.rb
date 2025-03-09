class RemovePropertyIdFromUpsells < ActiveRecord::Migration[8.0]
  def change
    remove_reference :upsells, :property, foreign_key: true, index: true
  end
end
