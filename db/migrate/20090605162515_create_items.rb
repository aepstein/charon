class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :requestable_id
      t.string :requestable_type
      t.decimal :request_amount
      t.string :requestor_comment
      t.integer :allocatable_id
      t.string :allocatable_type
      t.decimal :allocation_amount
      t.string :allocator_comment
      t.integer :request_id
      t.integer :node_id
      t.integer :parent_id
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end

