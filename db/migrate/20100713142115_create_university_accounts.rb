class CreateUniversityAccounts < ActiveRecord::Migration
  def self.up
    create_table :university_accounts do |t|
      t.string :department_code, :null => false
      t.string :subledger_code, :null => false
      t.references :organization, :null => false

      t.timestamps
    end
    add_index :university_accounts, [ :department_code, :subledger_code ], :unique => true
    add_index :university_accounts, :organization_id
  end

  def self.down
    remove_index :university_accounts, :organization_id
    remove_index :university_accounts, [ :department_code, :subledger_code ]
    drop_table :university_accounts
  end
end

