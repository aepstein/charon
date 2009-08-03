class CreateAttachmentTypes < ActiveRecord::Migration
  def self.up
    create_table :attachment_types do |t|
      t.string :name
      t.integer :max_size_quantity, :null => false
      t.string :max_size_unit, :null => false

      t.timestamps
    end
    create_table :attachment_types_nodes, :id => false do |t|
      t.references :attachment_type, :null => false
      t.references :node, :null => false
    end
    add_index :attachment_types_nodes,
              [ :attachment_type_id, :nodecl_id ],
              :unique => true
  end

  def self.down
    drop_table :attachment_types_nodes
    drop_table :attachment_types
  end
end

