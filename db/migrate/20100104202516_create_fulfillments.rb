class CreateFulfillments < ActiveRecord::Migration
  def self.up
    create_table :fulfillments do |t|
      t.references :fulfiller
      t.string :fulfiller_type
      t.references :fulfilled
      t.text :fulfilled_type

      t.timestamps
    end
  end

  def self.down
    drop_table :fulfillments
  end
end
