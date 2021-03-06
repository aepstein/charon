class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.integer :addressable_id
      t.string :addressable_type
      t.string :label
      t.string :street
      t.string :city
      t.string :state
      t.string :zip
      t.boolean :on_campus

      t.timestamps
    end
    add_index :addresses, [ :addressable_id, :addressable_type, :label ], :unique => true
  end

  def self.down
    drop_table :addresses
  end
end

