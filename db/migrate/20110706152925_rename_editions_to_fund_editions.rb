class RenameEditionsToFundEditions < ActiveRecord::Migration
  def self.up
    rename_table :editions, :fund_editions
    say_with_time 'Refactoring references from edition_id to fund_edition_id' do
      [ :administrative_expenses, :local_event_expenses, :travel_event_expenses,
        :publication_expenses, :durable_good_expenses, :speaker_expenses
      ].each do |t|
          remove_index t, :name => "index_#{t}_on_version_id"
          rename_column t, :edition_id, :fund_edition_id
          add_index t, :fund_edition_id, :unique => true
      end
      rename_column :external_equity_reports, :edition_id, :fund_edition_id
      add_index :external_equity_reports, :fund_edition_id, :unique => true
      remove_index :documents, :name => 'index_documents_on_version_id_and_document_type_id'
      rename_column :documents, :edition_id, :fund_edition_id
      add_index :documents, [ :fund_edition_id, :document_type_id ], :unique => true
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end

