class CreateAccountTransactions < ActiveRecord::Migration
  def self.up
    create_table :account_transactions do |t|
      t.string :status
      t.date :effective_on

      t.timestamps
    end
  end

  def self.down
    drop_table :account_transactions
  end
end
