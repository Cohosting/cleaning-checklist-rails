class CreateContractorSubcontractors < ActiveRecord::Migration[8.0]
  def change
    create_table :contractor_subcontractors do |t|
      t.references :contractor, null: false, foreign_key: { to_table: :users }
      t.references :subcontractor, null: false, foreign_key: { to_table: :users }
      
      t.timestamps
      
      t.index [:contractor_id, :subcontractor_id], unique: true
    end
  end
end
