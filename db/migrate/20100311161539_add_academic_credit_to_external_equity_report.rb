class AddAcademicCreditToExternalEquityReport < ActiveRecord::Migration
  def self.up
    add_column :external_equity_reports, :academic_credit, :boolean
  end

  def self.down
    remove_column :external_equity_reports, :academic_credit
  end
end
