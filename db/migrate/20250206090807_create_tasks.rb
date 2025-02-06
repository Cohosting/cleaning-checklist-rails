class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :checklist, null: false, foreign_key: true
      t.string :name, null: false
      t.boolean :completed, default: false

      t.timestamps
    end
  end
end
