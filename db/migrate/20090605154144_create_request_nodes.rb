class CreateRequestNodes < ActiveRecord::Migration
  def self.up
    create_table :request_nodes do |t|
      t.string :name
      t.string :requestable_type
      t.decimal :item_amount_limit
      t.integer :item_quantity_limit
      t.integer :request_structure_id
      t.integer :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :request_nodes
  end
end

