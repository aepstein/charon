class RenameRequestsToFundRequests < ActiveRecord::Migration
  def self.up
    rename_table :requests, :fund_requests
    say 'Refactoring references from request_id to fund_request_id'
    # The indices do not need to be re-created because we are getting rid of
    # the direct association.
    remove_index :items, [ :request_id, :node_id ]
    remove_index :items, :request_id
    rename_column :items, :request_id, :fund_request_id

    say 'Refactoring polymorphic associations'
    execute <<-SQL
      UPDATE approvals SET approvable_type = 'FundRequest'
      WHERE approvable_type = 'Request'
    SQL
  end

  def self.down
    raise IrreversibleMigration
  end
end

