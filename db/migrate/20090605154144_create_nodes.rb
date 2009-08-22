class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.string :name
      t.string :requestable_type, { :null => false }
      t.decimal :item_amount_limit, { :null => false, :default => 1000000.00 }
      t.integer :item_quantity_limit, { :null => false, :default => 1 }
      t.integer :structure_id, { :null => false }
      t.integer :parent_id

      t.timestamps
    end
    add_index :nodes, [ :structure_id, :name ], :unique => true
    add_index :nodes, [ :structure_id, :parent_id ]
  end

  def self.down
    drop_table :nodes
  end
end

