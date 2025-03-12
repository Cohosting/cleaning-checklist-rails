class AddNameDescriptionToJobSectionGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :job_section_groups, :name, :string, null: false, default: ""
    add_column :job_section_groups, :description, :text, null: false, default: ""
    
  end

  
end
