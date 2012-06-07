class AddFundTierIdToFundRequests < ActiveRecord::Migration
  def change
    add_column :fund_requests, :fund_tier_id, :integer
    add_index :fund_requests, :fund_tier_id
  end
end

