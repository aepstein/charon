class AddAmountToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :amount, :decimal, :default => 0.0
  end

  def self.down
    remove_column :items, :amount
  end
end

