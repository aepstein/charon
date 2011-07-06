class AddFundGrantIdToRequests < ActiveRecord::Migration
  def self.up
    say_with_time 'Set up fund_grants corresponding to existing fund_requests' do
      execute <<-SQL
        INSERT INTO fund_grants ( organization_id, fund_source_id, state,
          created_at, updated_at )
        SELECT organization_id, basis_id, 'new', MIN(created_at),
          MAX(updated_at) FROM fund_requests GROUP BY organization_id, basis_id
      SQL
    end
    say_with_time 'Associate fund_requests with corresponding fund_grants' do
      add_column :fund_requests, :fund_grant_id, :integer
      add_index :fund_requests, [ :fund_grant_id, :state ], :unique => true
      execute <<-SQL
        UPDATE fund_requests SET fund_grant_id = (
          SELECT id FROM fund_grants WHERE
            organization_id = fund_requests.organization_id AND
            fund_source_id = fund_requests.fund_source_id
        )
      SQL
      change_column :requests, :fund_grant_id, :integer, :null => false
    end
    say_with_time 'Remove deprecated references from fund_requests' do
      remove_index :fund_requests, [ :fund_source_id, :state ]
      remove_column :fund_requests, :fund_source_id
      remove_column :fund_requests, :organization_id
    end
    say_with_time "Associate fund_items with fund_requests' fund_grants" do
      add_column :fund_items, :fund_grant_id, :integer
      execute <<-SQL
        UPDATE fund_items SET fund_grant_id = (
          SELECT fund_grant_id FROM fund_requests WHERE
            id = fund_items.fund_request_id
        )
      SQL
      change_column :fund_items, :fund_grant_id, :integer, :null => false
    end
    say_with_time "Associate fund editions with fund_items' fund requests" do
      add_column :fund_editions, :fund_request_id, :integer
      execute <<-SQL
        UPDATE fund_editions SET fund_request_id = (
          SELECT fund_request_id FOM fund_items WHERE
            id = fund_editions.fund_item_id
        )
      SQL
      change_column :fund_editions, :fund_request_id, :integer, :null => false
    end
    say_with_time "Remove deprecated references from fund_items" do
      remove_column :fund_items, :fund_request_id
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end

