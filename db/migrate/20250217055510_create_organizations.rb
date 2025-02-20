class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.references :owner, foreign_key: { to_table: :users } # Organization creator

      t.timestamps
    end
  end
end
