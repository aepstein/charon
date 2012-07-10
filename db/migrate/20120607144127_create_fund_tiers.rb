class CreateFundTiers < ActiveRecord::Migration
  def change
    create_table :fund_tiers do |t|
      t.references :organization, null: false
      t.decimal :maximum_allocation, precision: 10, scale: 2, null: false

      t.timestamps
    end
    add_index :fund_tiers, :organization_id
  end
end

