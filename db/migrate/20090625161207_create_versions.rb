class CreateVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.integer :item_id
      t.string :requestable_type
      t.integer :requestable_id
      t.decimal :amount
      t.text :comment
      t.integer :stage_id

      t.timestamps
    end
  end

  def self.down
    drop_table :versions
  end
end
