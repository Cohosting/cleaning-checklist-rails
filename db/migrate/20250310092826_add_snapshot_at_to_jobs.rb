class AddSnapshotAtToJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :jobs, :snapshot_at,      :datetime,      null: true,  default: nil
  end
end
