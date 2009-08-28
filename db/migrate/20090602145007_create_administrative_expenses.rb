class CreateAdministrativeExpenses < ActiveRecord::Migration
  def self.up
    create_table :administrative_expenses do |t|
      t.integer :copies, { :null => false, :default => 0 }
      t.decimal :repairs_restocking, { :null => false, :default => 0 }
      t.integer :mailbox_wsh, { :null => false, :default => 0 }
      t.integer :version_id, :null => false

      t.timestamps
    end
    add_index :administrative_expenses, :version_id, :unique => true
  end

  def self.down
    drop_table :administrative_expenses
  end
end

