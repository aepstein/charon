class ExternalEquityReport < ActiveRecord::Base
  attr_accessible :anticipated_expenses, :anticipated_income, :current_assets,
    :current_liabilities, :academic_credit
  attr_readonly :edition_id

  belongs_to :edition, :inverse_of => :external_equity_report

  validates_presence_of :edition
  validates_numericality_of :anticipated_income, :greater_than_or_equal_to => 0.0
  validates_numericality_of :anticipated_expenses, :greater_than_or_equal_to => 0.0
  validates_numericality_of :current_assets, :greater_than_or_equal_to => 0.0
  validates_numericality_of :current_liabilities, :greater_than_or_equal_to => 0.0

  def net_equity
    return unless anticipated_income && current_assets && anticipated_expenses && current_liabilities
    anticipated_income + current_assets - anticipated_expenses - current_liabilities
  end

  def max_request; 0.0; end

  def title; nil; end
end

