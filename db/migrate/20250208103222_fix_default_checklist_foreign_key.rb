class FixDefaultChecklistForeignKey < ActiveRecord::Migration[8.0]
  def change
    remove_column :properties, :default_checklist_id, :integer
    add_reference :properties, :default_checklist, foreign_key: { to_table: :checklists }, type: :bigint
  end
end
