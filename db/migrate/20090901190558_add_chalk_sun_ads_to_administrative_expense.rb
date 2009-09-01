class AddChalkSunAdsToAdministrativeExpense < ActiveRecord::Migration
  def self.up
    add_column :administrative_expenses, :chalk, :integer, :null => false, :default => 0
    add_column :administrative_expenses, :sun_ads, :decimal, :null => false, :default => 0
  end

  def self.down
    remove_column :administrative_expenses, :sun_ads
    remove_column :administrative_expenses, :chalk
  end
end

