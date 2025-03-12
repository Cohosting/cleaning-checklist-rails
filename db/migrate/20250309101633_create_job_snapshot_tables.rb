class CreateJobSnapshotTables < ActiveRecord::Migration[8.0]
  def change
    create_table :job_sections do |t|
      t.string :title
      t.integer :position
      t.references :job, null: false, foreign_key: true
      
      t.timestamps
    end
    
    create_table :job_section_groups do |t|
      t.references :job_section, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.integer :position
      
      t.timestamps
    end
    
    # Modify existing job_tasks table
    remove_reference :job_tasks, :job
    add_reference :job_tasks, :job_section_group, null: false, foreign_key: true
  end
end
