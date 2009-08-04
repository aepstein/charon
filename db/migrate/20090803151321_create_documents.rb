class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.integer :attachable_id
      t.string :attachable_type
      t.references :document_type

      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end

