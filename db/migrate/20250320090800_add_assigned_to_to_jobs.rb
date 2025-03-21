class AddAssignedToToJobs < ActiveRecord::Migration[8.0]
  def change
    add_reference :jobs, :assigned_to, foreign_key: { to_table: :memberships }
  end
end
