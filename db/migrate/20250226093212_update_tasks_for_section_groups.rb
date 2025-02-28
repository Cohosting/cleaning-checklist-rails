class UpdateTasksForSectionGroups < ActiveRecord::Migration[8.0]
  def change
    add_reference :tasks, :section_group, foreign_key: true
    
    # Remove the section reference as tasks will now belong to section_groups
    remove_reference :tasks, :section, foreign_key: true
  end
end
