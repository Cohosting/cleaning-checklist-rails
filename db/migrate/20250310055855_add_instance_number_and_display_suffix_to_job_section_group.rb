class AddInstanceNumberAndDisplaySuffixToJobSectionGroup < ActiveRecord::Migration[8.0]
  def change
    add_column :job_section_groups, :instance_number, :integer, null: false, default: 0
    add_column :job_section_groups, :display_suffix, :string, null: false, default: ""
  end
end
