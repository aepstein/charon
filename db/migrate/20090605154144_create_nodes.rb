class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.string :name
      t.string :requestable_type
      t.decimal :item_amount_limit
      t.integer :item_quantity_limit
      t.integer :structure_id
      t.integer :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :nodes
  end
end

