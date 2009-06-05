class CreateDurableGoodExpenses < ActiveRecord::Migration
  def self.up
    create_table :durable_good_expenses do |t|
      t.string :description
      t.float :quantity
      t.float :price
      t.decimal :total

      t.timestamps
    end
  end

  def self.down
    drop_table :durable_good_expenses
  end
end
