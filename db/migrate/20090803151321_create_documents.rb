class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.references :version
      t.references :document_type

      t.timestamps
    end
    add_index :documents, [:version_id, :document_type_id], :unique => true
  end

  def self.down
    drop_table :documents
  end
end

