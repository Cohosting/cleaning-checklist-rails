class CreateContractorProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :contractor_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.json :settings, default: {}, null: false
      
      t.timestamps
    end
  end
end
