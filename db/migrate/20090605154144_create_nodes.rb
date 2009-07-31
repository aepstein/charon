class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.string :name
      t.string :requestable_type
      t.decimal :item_amount_limit, { :null => false, :default => 1000000.00 }
      t.integer :item_quantity_limit, { :null => false, :default => 1 }
      t.integer :structure_id
      t.integer :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :nodes
  end
end

