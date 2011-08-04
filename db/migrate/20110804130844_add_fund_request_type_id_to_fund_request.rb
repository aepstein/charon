class AddFundRequestTypeIdToFundRequest < ActiveRecord::Migration
  def change
    add_column :fund_requests, :fund_request_type_id, :integer
  end
end

