class CreateJobTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :job_tasks do |t|
      t.references :job, null: false, foreign_key: true
      t.string :name
      t.boolean :completed, default: false

      t.timestamps
    end
  end
end
