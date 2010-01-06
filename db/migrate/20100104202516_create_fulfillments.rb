class CreateFulfillments < ActiveRecord::Migration
  def self.up
    create_table :fulfillments do |t|
      t.references :fulfiller, :null => false, :polymorphic => true
      t.references :fulfillable, :null => false, :polymorphic => true

      t.timestamp :created_at, :null => false
    end
    add_index :fulfillments, [ :fulfiller_id, :fulfiller_type, :fulfillable_id, :fulfillable_type ],
      :unique => true, :name => 'fulfillments_unique'
  end

  def self.down
    remove_index :fullfillments, :fulfillments_unique
    drop_table :fulfillments
  end
end

