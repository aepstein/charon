class RenameEditionsToFundEditions < ActiveRecord::Migration
  def self.up
    rename_table :editions, :fund_editions
    say_with_time 'Refactoring references from edition_id to fund_edition_id' do
      [ :administrative_expenses, :local_event_expenses, :travel_event_expenses,
        :publication_expenses, :durable_good_expenses, :speaker_expenses,
        :external_equity_reports ].each do |t|
          remove_index t, :edition_id
          rename_column t, :edition_id, :fund_edition_id
          add_index t, :fund_edition_id, :unique => true
      end
      remove_index :documents, [ :edition_id, :document_type_id ]
      rename_column :documents, :edition_id, :fund_edition_id
      add_index :documents, [ :fund_edition_id, :document_type_id ], :unique => true
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end

