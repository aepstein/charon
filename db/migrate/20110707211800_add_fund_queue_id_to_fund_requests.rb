class AddFundQueueIdToFundRequests < ActiveRecord::Migration
  def self.up
    add_column :fund_requests, :fund_queue_id, :integer
    add_index :fund_requests, :fund_queue_id
  end

  def self.down
    remove_index :fund_requests, :fund_queue_id
    remove_column :fund_requests, :fund_queue_id
  end
end

