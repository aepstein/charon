class CreateFundSourcesFundTiers < ActiveRecord::Migration
  def change
    create_table :fund_sources_fund_tiers, id: false do |t|
      t.references :fund_source, null: false
      t.references :fund_tier, null: false
    end
    add_index :fund_sources_fund_tiers, [ :fund_source_id, :fund_tier_id ],
      unique: true, name: 'fund_source_fund_tiers_primary'
  end

end

