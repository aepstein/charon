class RenameBasesToFundSources < ActiveRecord::Migration
  def self.up
    rename_table :bases, :fund_sources
    say_with_time 'Refactoring references from basis_id to fund_source_id' do
      remove_index :requests, [ :basis_id, :state ]
      rename_column :requests, :basis_id, :fund_source_id
      add_index :requests, [ :fund_source_id, :state ]
      remove_index :activity_accounts, :name => 'unique_activity_accounts'
      rename_column :activity_accounts, :basis_id, :fund_source_id
      add_index :activity_accounts,
        [ :university_account_id, :fund_source_id, :category_id ],
        :name => 'unique_activity_accounts', :unique => true
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end

