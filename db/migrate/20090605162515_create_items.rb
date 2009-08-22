class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :request_id
      t.integer :node_id
      t.integer :parent_id
      t.integer :position

      t.timestamps
    end
    add_index :items, :request_id
    add_index :items, [ :request_id, :node_id ]
    add_index :items, :parent_id
  end

  def self.down
    drop_table :items
  end
end

