class AddFundGrantIdToActivityAccount < ActiveRecord::Migration
  def up
    add_column :activity_accounts, :fund_grant_id, :integer
    remove_index :activity_accounts, name: 'unique_activity_accounts'
    add_index :activity_accounts, [ :fund_grant_id, :category_id ],
      unique: true, name: 'unique_activity_accounts'
    execute <<-SQL
      UPDATE activity_accounts SET fund_grant_id =
      (SELECT fund_grants.id FROM fund_grants INNER JOIN university_accounts
      ON fund_grants.organization_id = university_accounts.organization_id WHERE
      fund_grants.fund_source_id = activity_accounts.fund_source_id AND
      university_accounts.id = activity_accounts.university_account_id
      LIMIT 1)
    SQL
    remove_column :activity_accounts, :fund_source_id
    remove_column :activity_accounts, :university_account_id
    change_column :activity_accounts, :fund_grant_id, :integer, null: false
  end

  def down
    raise IrreversibleMigration
  end
end

