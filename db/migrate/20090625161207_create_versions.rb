class CreateVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.integer :item_id, :null => false
      t.decimal :amount, :null => false
      t.text :comment
      t.string :perspective, { :null => false }

      t.timestamps
    end
    add_index :versions, [ :item_id, :perspective ], :unique => true
  end

  def self.down
    drop_table :versions
  end
end

