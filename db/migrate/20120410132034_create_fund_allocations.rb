class CreateFundAllocations < ActiveRecord::Migration
  def up
    create_table :fund_allocations do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.references :fund_item, null: false
      t.references :fund_request, null: false
      t.timestamps
    end
    add_index :fund_allocations, :fund_item_id
    add_index :fund_allocations, :fund_request_id
    add_index :fund_allocations, [ :fund_item_id, :fund_request_id ],
      unique: true
    say 'Populating initial fund_allocations...'
    execute <<-SQL
      INSERT INTO fund_allocations ( amount, state, fund_item_id,
      fund_request_id, created_at, updated_at ) SELECT
      IF(fund_grants.released_at IS NOT NULL,released_amount,amount),
      IF(fund_grants.released_at IS NOT NULL,'released','unreleased'),
      fund_items.id, fund_requests.id, fund_items.updated_at, fund_items.updated_at
      FROM fund_requests INNER JOIN fund_grants ON
      fund_requests.fund_grant_id = fund_grants.id INNER JOIN fund_items ON
      fund_grants.id = fund_items.fund_grant_id
      WHERE fund_requests.state = 'released'
      GROUP BY fund_items.id
      ORDER BY fund_requests.updated_at DESC
    SQL
    remove_column :fund_items, :amount
    remove_column :fund_items, :released_amount
  end

  def down
    remove_index :fund_allocations, [ :fund_item_id, :fund_request_id ]
    remove_index :fund_allocations, :fund_request_id
    remove_index :fund_allocations, :fund_item_id
    drop_table :fund_allocations
  end
end

