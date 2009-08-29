class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :request_id, :null => false
      t.integer :node_id, :null => false
      t.integer :parent_id
      t.integer :position
      t.string :title, :null => false

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

