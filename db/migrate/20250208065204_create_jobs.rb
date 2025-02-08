class CreateJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :jobs do |t|
      t.references :property, null: false, foreign_key: true
      t.references :checklist, null: false, foreign_key: true
      t.date :date

      t.timestamps
    end
  end
end
