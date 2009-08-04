class CreateDocumentTypes < ActiveRecord::Migration
  def self.up
    create_table :document_types do |t|
      t.string :name
      t.integer :max_size_quantity, :null => false
      t.string :max_size_unit, :null => false

      t.timestamps
    end
    create_table :document_types_nodes, :id => false do |t|
      t.references :document_type, :null => false
      t.references :node, :null => false
    end
    add_index :document_types_nodes,
              [ :document_type_id, :node_id ],
              :unique => true
  end

  def self.down
    drop_table :document_types_nodes
    drop_table :document_types
  end
end

