class AddPositionToUpsells < ActiveRecord::Migration[8.0]
  def change
    add_column :upsells, :position, :integer
    add_index :upsells, :position
    
    # Initialize positions for existing records
    reversible do |dir|
      dir.up do
        # Group by organization_id and assign sequential positions
        execute <<~SQL
          WITH ordered_upsells AS (
            SELECT id, ROW_NUMBER() OVER (PARTITION BY organization_id ORDER BY created_at) as row_num
            FROM upsells
          )
          UPDATE upsells
          SET position = ordered_upsells.row_num
          FROM ordered_upsells
          WHERE upsells.id = ordered_upsells.id
        SQL
      end
    end
  end
end
