class RenameVersionsTable < ActiveRecord::Migration
  AFFECTED_TABLES = [ :administrative_expenses, :documents, :durable_good_expenses, :local_event_expenses, :publication_expenses, :speaker_expenses, :travel_event_expenses ]

  def self.up
    rename_table :versions, :editions
    RenameVersionsTable::AFFECTED_TABLES.each do |table|
      rename_column table, :version_id, :edition_id
    end
  end

  def self.down
    rename_table :editions, :versions
    RenameVersionsTable::AFFECTED_TABLES.each do |table|
      rename_column table, :edition_id, :version_id
    end
  end
end

