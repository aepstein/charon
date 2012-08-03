class CreateFundTierAssignments < ActiveRecord::Migration
  def change
    create_table :fund_tier_assignments do |t|
      t.references :fund_source, null: false
      t.references :organization, null: false
      t.references :fund_tier, null: false

      t.timestamps
    end
    add_index :fund_tier_assignments, :fund_source_id
    add_index :fund_tier_assignments, :organization_id
    add_index :fund_tier_assignments, :fund_tier_id
    add_index :fund_tier_assignments, [ :fund_source_id, :organization_id ],
      name: :unique_assignment, unique: true
    add_column :fund_grants, :fund_tier_assignment_id, :integer
    add_index :fund_grants, :fund_tier_assignment_id,
      name: :unique_tier_assignment, unique: true
  end
end

