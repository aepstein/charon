class CreateDurableGoodExpenses < ActiveRecord::Migration
  def self.up
    create_table :durable_good_expenses do |t|
      t.string :description, :null => false
      t.float :quantity, :null => false
      t.float :price, :null => false
      t.integer :version_id

      t.timestamps
    end
    add_index :durable_good_expenses, :version_id, :unique => true
  end

  def self.down
    drop_table :durable_good_expenses
  end
end

