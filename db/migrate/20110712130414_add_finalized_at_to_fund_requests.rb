class AddFinalizedAtToFundRequests < ActiveRecord::Migration
  def self.up
    add_column :fund_requests, :finalized_at, :datetime

    say 'Populating finalized_at for finalized requests'
    execute <<-SQL
      UPDATE fund_requests SET finalized_at = (SELECT MAX(created_at)
      FROM approvals WHERE approvable_type = 'FundRequest' AND
      approvable_id = fund_requests.id)
      WHERE request_state = 'finalized'
    SQL
  end

  def self.down
    remove_column :fund_requests, :finalized_at
  end
end

