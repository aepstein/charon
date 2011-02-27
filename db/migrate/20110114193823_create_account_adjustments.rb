class CreateAccountAdjustments < ActiveRecord::Migration
  def self.up
    create_table :account_adjustments do |t|
      t.references :account_transaction, :null => false
      t.references :activity_account, :null => false
      t.decimal :amount, :null => false, :scale => 2

      t.timestamps
    end
    add_index :account_adjustments, [ :account_transaction_id, :activity_account_id ],
      :name => :account_adjustments_unique, :unique => false
  end

  def self.down
    remove_index :account_adjustments, :name => :account_adjustments_unique
    drop_table :account_adjustments
  end
end

