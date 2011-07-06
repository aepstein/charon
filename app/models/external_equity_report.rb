class ExternalEquityReport < ActiveRecord::Base
  attr_accessible :anticipated_expenses, :anticipated_income, :current_assets,
    :current_liabilities, :academic_credit
  attr_readonly :fund_edition_id

  belongs_to :fund_edition, :inverse_of => :external_equity_report

  has_paper_trail :class_name => 'SecureVersion'

  validates :fund_edition, :presence => true
  validates :anticipated_income,
    :numericality => { :greater_than_or_equal_to => 0.0 }
  validates :anticipated_expenses,
    :numericality => { :greater_than_or_equal_to => 0.0 }
  validates :current_assets,
    :numericality => { :greater_than_or_equal_to => 0.0 }
  validates :current_liabilities,
    :numericality => { :greater_than_or_equal_to => 0.0 }

  def net_equity
    return unless anticipated_income && current_assets && anticipated_expenses && current_liabilities
    anticipated_income + current_assets - anticipated_expenses - current_liabilities
  end

  def max_fund_request; 0.0; end

  def title; nil; end
end

