class AddFundGrantIdToRequests < ActiveRecord::Migration
  def self.up
    say 'Add fund_grants corresponding to existing fund_requests'
    execute <<-SQL
      INSERT INTO fund_grants ( organization_id, fund_source_id,
        created_at, updated_at )
      SELECT DISTINCT organization_id, fund_source_id, MIN(created_at),
        MAX(updated_at) FROM fund_requests GROUP BY organization_id, fund_source_id
    SQL

    say 'Associate fund_requests with corresponding fund_grants'
    add_column :fund_requests, :fund_grant_id, :integer
    add_index :fund_requests, [ :fund_grant_id, :state ]
    execute <<-SQL
      UPDATE fund_requests SET fund_grant_id = (
        SELECT id FROM fund_grants WHERE
          organization_id = fund_requests.organization_id AND
          fund_source_id = fund_requests.fund_source_id
      )
    SQL
    change_column :fund_requests, :fund_grant_id, :integer, :null => false

    say 'Mark fund grants released according to corresponding request flag'
    execute <<-SQL
      UPDATE fund_grants SET released_at = (
        SELECT MAX( released_at ) FROM fund_requests WHERE
        fund_grant_id = fund_grants.id
      )
    SQL

    say 'Remove deprecated references from fund_requests'
    remove_index :fund_requests, :name => 'index_requests_on_fund_source_id_and_state'
    remove_column :fund_requests, :fund_source_id
    remove_column :fund_requests, :organization_id

    say "Associate fund_items with fund_requests' fund_grants"
    add_column :fund_items, :fund_grant_id, :integer
    execute <<-SQL
      UPDATE fund_items SET fund_grant_id = (
        SELECT fund_grant_id FROM fund_requests WHERE
          id = fund_items.fund_request_id
      )
    SQL
    change_column :fund_items, :fund_grant_id, :integer, :null => false

    say "Associate fund editions with fund_items' fund requests"
    add_column :fund_editions, :fund_request_id, :integer
    execute <<-SQL
      UPDATE fund_editions SET fund_request_id = (
        SELECT fund_request_id FROM fund_items WHERE
          id = fund_editions.fund_item_id
      )
    SQL
    change_column :fund_editions, :fund_request_id, :integer, :null => false

    say "Remove deprecated references from fund_items"
    remove_column :fund_items, :fund_request_id
  end

  def self.down
    raise IrreversibleMigration
  end
end

