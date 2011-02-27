class CreateActivityAccounts < ActiveRecord::Migration
  def self.up
    create_table :activity_accounts do |t|
      t.references :university_account, :null => false
      t.references :basis
      t.references :category
      t.text :comments

      t.timestamps
    end
    add_index :activity_accounts, [ :university_account_id, :basis_id, :category_id ],
      :unique => true, :name => :unique_activity_accounts
  end

  def self.down
    remove_index :activity_accounts, :name => :unique_activity_accounts
    drop_table :activity_accounts
  end
end

