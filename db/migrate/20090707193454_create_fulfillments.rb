class CreateFulfillments < ActiveRecord::Migration
  def self.up
    create_table :fulfillments do |t|
      t.integer :condition_id
      t.string :condition_type
      t.integer :fulfiller_id
      t.string :fulfiller_type

      t.timestamps
    end
  end

  def self.down
    drop_table :fulfillments
  end
end
