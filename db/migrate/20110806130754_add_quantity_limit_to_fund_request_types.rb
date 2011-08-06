class AddQuantityLimitToFundRequestTypes < ActiveRecord::Migration
  def change
    add_column :fund_request_types, :quantity_limit, :integer
  end
end
