class CreateRequestItems < ActiveRecord::Migration
  def self.up
    create_table :request_items do |t|
      t.integer :requestable_id
      t.string :requestable_type
      t.decimal :request_amount
      t.string :requestor_comment
      t.decimal :allocation_amount
      t.string :allocator_comment
      t.integer :request_id
      t.integer :request_node_id
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :request_items
  end
end

