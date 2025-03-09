class CreatePropertyGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :property_groups do |t|
      t.references :property, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
