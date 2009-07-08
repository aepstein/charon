class CreateAdministrativeExpenses < ActiveRecord::Migration
  def self.up
    create_table :administrative_expenses do |t|
      t.integer :copies
      t.decimal :copies_expense
      t.decimal :repairs_restocking
      t.integer :mailbox_wsh
      t.decimal :total
      t.integer :version_id

      t.timestamps
    end

  end

  def self.down
    drop_table :administrative_expenses
  end
end

