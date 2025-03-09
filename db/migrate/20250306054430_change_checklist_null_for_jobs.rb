class ChangeChecklistNullForJobs < ActiveRecord::Migration[8.0]
  def change
    change_column_null :jobs, :checklist_id, true
  end
end
