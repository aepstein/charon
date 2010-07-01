class RemoveFundingSourcesFromRegistration < ActiveRecord::Migration
  def self.up
    remove_column :registrations, :funding_sources
  end

  def self.down
    add_column :registrations, :funding_sources, :string
  end
end
