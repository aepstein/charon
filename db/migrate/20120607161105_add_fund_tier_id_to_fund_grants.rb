class AddFundTierIdToFundGrants < ActiveRecord::Migration
  def change
    add_column :fund_grants, :fund_tier_id, :integer
    add_index :fund_grants, :fund_tier_id
  end
end

