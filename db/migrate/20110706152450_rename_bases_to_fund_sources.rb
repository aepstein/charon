class RenameBasesToFundSources < ActiveRecord::Migration
  def self.up
    rename_table :bases, :fund_sources
    # Refactor references
    say_with_time 'Refactoring references from basis_id to fund_source_id' do
      remove_index :requests, [ :basis_id, :state ]
      rename_column :requests, :basis_id, :fund_source_id
      add_index :requests, [ :fund_source_id, :state ], :unique => true
      remove_index :activity_accounts, [ :university_account_id, :basis_id, :category_id ]
      rename_column :activity_accounts, :basis_id, :fund_source_id
      add_index :activity_accounts, [ :university_account_id, :fund_source_id, :category_id ], :unique => true
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end

