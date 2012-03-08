class AddAccountCodeToUniversityAccounts < ActiveRecord::Migration
  def up
    add_column :university_accounts, :account_code, :string
    execute <<-SQL
      UPDATE university_accounts SET account_code =
      CONCAT( department_code, subledger_code )
    SQL
    change_column :university_accounts, :account_code, :string, :null => false
    remove_index :university_accounts, :name => 'unique_code'
    add_index :university_accounts, [ :account_code, :subaccount_code ],
      :name => 'unique_code', :unique => true
    remove_column :university_accounts, :department_code
    remove_column :university_accounts, :subledger_code
  end

  def down
    raise IrreversibleMigration
  end
end

