class FixAccountAdjustmentsAmount < ActiveRecord::Migration
  def self.up
    change_column :account_adjustments, :amount, :decimal, :default => 0.0, :precision => 10, :scale => 2, :null => false
  end

  def self.down
    raise IrreversibleMigration
  end
end

