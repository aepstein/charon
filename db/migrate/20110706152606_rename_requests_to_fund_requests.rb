class RenameRequestsToFundRequests < ActiveRecord::Migration
  def self.up
    rename_table :requests, :fund_requests
    say_with_time 'Refactoring references from request_id to fund_request_id' do
      # The indices do not need to be re-created because we are getting rid of
      # the direct association.
      remove_index :items, [ :request_id, :node_id ]
      remove_index :items, :request_id
      rename_column :items, :request_id, :fund_request_id
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end

