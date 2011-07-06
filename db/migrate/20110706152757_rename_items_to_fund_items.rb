class RenameItemsToFundItems < ActiveRecord::Migration
  def self.up
    rename_table :items, :fund_items
    say_with_time 'Refactoring references from item_id to fund_item_id' do
      remove_index :editions, [ :item_id, :perspective ]
      rename_column :editions, :item_id, :fund_item_id
      add_index :editions, [ :fund_item_id, :perspective ], :unique => true
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end

