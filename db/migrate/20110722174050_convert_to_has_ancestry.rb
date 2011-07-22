class ConvertToHasAncestry < ActiveRecord::Migration
  # Define stub classes to skip business logic
  class Node < ActiveRecord::Base
    record_timestamps = false
    has_ancestry
  end
  class FundItem < ActiveRecord::Base
    record_timestamps = false
    has_ancestry
  end

  def self.up
    say 'Converting nodes to ancestry'
    add_column :nodes, :ancestry, :string
    add_index :nodes, [ :structure_id, :ancestry ]
    Node.reset_column_information
    say_with_time 'Building new ancestries and verifying integrity' do
      Node.build_ancestry_from_parent_ids!
      Node.check_ancestry_integrity!
    end
    remove_index :nodes, [ :structure_id, :parent_id ]
    remove_column :nodes, :parent_id

    say 'Converting fund_items to ancestry'
    add_column :fund_items, :ancestry, :string
    add_index :fund_items, [ :fund_grant_id, :ancestry ]
    FundItem.reset_column_information
    say_with_time 'Building new ancestries and verifying integrity' do
      FundItem.build_ancestry_from_parent_ids!
      FundItem.check_ancestry_integrity!
    end
    remove_index :fund_items, :name => "index_items_on_parent_id"
    remove_column :fund_items, :parent_id
  end

  def self.down
    raise IrreversibleMigration
  end
end

