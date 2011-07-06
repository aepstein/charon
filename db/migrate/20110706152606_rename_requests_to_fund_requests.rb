class RenameRequestsToFundRequests < ActiveRecord::Migration
  def self.up
    rename_table :requests, :fund_requests
    # Refactor references
    say_with_time 'Refactoring references from request_id to fund_request_id' do
      remove_index :items, [ :request_id, :node_id ]
      remove_index :items, :request_id # We won't restore this one
      rename_column :items, :request_id, :fund_request_id
      add_index :items, [ :request_id, :node_id ], :unique => true
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end

