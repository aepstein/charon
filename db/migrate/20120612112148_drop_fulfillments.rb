class DropFulfillments < ActiveRecord::Migration
  def up
    remove_index :fulfillments, name: :fulfillments_unique
    drop_table :fulfillments
  end

  def down
    raise IrreversibleMigration
  end
end

