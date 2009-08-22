class CreateDurableGoodExpenses < ActiveRecord::Migration
  def self.up
    create_table :durable_good_expenses do |t|
      t.string :description
      t.float :quantity
      t.float :price
      t.decimal :total
      t.integer :version_id

      t.timestamps
    end
    add_index :durable_good_expenses, :version_id
  end

  def self.down
    drop_table :durable_good_expenses
  end
end

