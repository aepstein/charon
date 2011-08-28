class AddReleasedAmountToFundItems < ActiveRecord::Migration
  def up
    add_column :fund_items, :released_amount, :decimal, :precision => 10,
      :scale => 2, :null => false, :default => 0.0
    change_column :fund_items, :amount, :decimal, :precision => 10,
      :scale => 2, :null => false, :default => 0.0
    change_column :fund_editions, :amount, :decimal, :precision => 10,
      :scale => 2, :null => false, :default => 0.0
  end

  def down
    remove_column :fund_items, :released_amount
  end
end

