class CreateJobAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :job_assignments do |t|
      t.references :job, null: false, foreign_key: true
      t.references :subcontractor, null: false, foreign_key: { to_table: :users }
      t.references :assigned_by, null: false, foreign_key: { to_table: :users }
      t.text :notes
      t.timestamps
    end
    
    # Add an index to improve query performance
    add_index :job_assignments, [:job_id, :subcontractor_id], unique: true
  end
end