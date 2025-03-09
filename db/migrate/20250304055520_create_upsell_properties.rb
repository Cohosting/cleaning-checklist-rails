class CreateUpsellProperties < ActiveRecord::Migration[8.0]
  def change
    create_table :upsell_properties do |t|
      t.references :upsell, null: false, foreign_key: true
      t.references :property, null: false, foreign_key: true
      
      t.timestamps
    end
    
    add_index :upsell_properties, [:upsell_id, :property_id], unique: true
  end
end
