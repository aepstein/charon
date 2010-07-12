class CreateInventoryItems < ActiveRecord::Migration
  def self.up
    create_table :inventory_items do |t|
      t.references :organization, :null => false
      t.decimal :purchase_price, :null => false, :scale => 2
      t.decimal :current_value, :null => false, :scale => 2
      t.string :description, :null => false
      t.string :identifier
      t.text :comments
      t.boolean :usable, :null => false, :default => true
      t.boolean :missing, :null => false, :default => false
      t.date :acquired_on, :null => false
      t.date :scheduled_retirement_on, :null => false
      t.date :retired_on

      t.timestamps
    end
    add_index :inventory_items, :organization_id
    add_index :inventory_items, [ :organization_id, :identifier ], :unique => true
    add_index :inventory_items, [ :organization_id, :acquired_on ]
  end

  def self.down
    remove_index :inventory_items, [ :organization_id, :acquired_on ]
    remove_index :inventory_items, [ :organization_id, :identifier ]
    remove_index :inventory_items, :organization_id
    drop_table :inventory_items
  end
end

