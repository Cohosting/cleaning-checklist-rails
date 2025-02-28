class CreateSectionGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :section_groups do |t|
      t.references :section, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
