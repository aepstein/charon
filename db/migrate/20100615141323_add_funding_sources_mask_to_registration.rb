class AddFundingSourcesMaskToRegistration < ActiveRecord::Migration
  def self.up
    add_column :registrations, :funding_sources_mask, :integer
  end

  def self.down
    remove_column :registrations, :funding_sources_mask
  end
end
