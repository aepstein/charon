class CreateExternalEquityReports < ActiveRecord::Migration
  def self.up
    create_table :external_equity_reports do |t|
      t.decimal :anticipated_expenses, :precision => 13, :scale => 2, :default => 0.0, :null => false
      t.decimal :anticipated_income, :precision => 13, :scale => 2, :default => 0.0, :null => false
      t.decimal :current_assets, :precision => 13, :scale => 2, :default => 0.0, :null => false
      t.decimal :current_liabilities, :precision => 13, :scale => 2, :default => 0.0, :null => false

      t.references :edition, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :external_equity_reports
  end
end

