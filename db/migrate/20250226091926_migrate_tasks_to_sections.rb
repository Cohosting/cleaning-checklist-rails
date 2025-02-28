class MigrateTasksToSections < ActiveRecord::Migration[8.0]
  def up
    # Add section_id column to tasks (if not already added)
    unless column_exists?(:tasks, :section_id)
      add_reference :tasks, :section, foreign_key: true
    end
    
    # Find all checklists
    Checklist.find_each do |checklist|
      # Create a default section for each checklist
      section = checklist.sections.create!(title: "General")
      
      # Move existing tasks to this section
      execute <<-SQL
        UPDATE tasks
        SET section_id = #{section.id}
        WHERE checklist_id = #{checklist.id}
      SQL
    end
    
    # Make section_id required
    change_column_null :tasks, :section_id, false
    
    # Remove the direct association between tasks and checklists
    remove_reference :tasks, :checklist, foreign_key: true
  end
  
  def down
    # Add checklist_id column back to tasks
    add_reference :tasks, :checklist, foreign_key: true
    
    # Migrate tasks back to direct checklist association
    Section.find_each do |section|
      execute <<-SQL
        UPDATE tasks
        SET checklist_id = #{section.checklist_id}
        WHERE section_id = #{section.id}
      SQL
    end
    
    # Make checklist_id required
    change_column_null :tasks, :checklist_id, false
    
    # Remove the section association
    remove_reference :tasks, :section, foreign_key: true
  end
end
