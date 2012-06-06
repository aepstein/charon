class OrganizationProfile < ActiveRecord::Base
  attr_accessible :anticipated_expenses, :anticipated_income, :current_assets,
    :current_liabilities, :academic_credit, as: [ :admin, :default ]
  attr_readonly :organization_id

  belongs_to :organization, inverse_of: :organization_profile

  has_paper_trail class_name: 'SecureVersion'

  validates :organization, presence: true
  validates :organization_id, uniqueness: true
  validates :anticipated_income,
    numericality: { greater_than_or_equal_to: 0.0 }
  validates :anticipated_expenses,
    numericality: { greater_than_or_equal_to: 0.0 }
  validates :current_assets,
    numericality: { greater_than_or_equal_to: 0.0 }
  validates :current_liabilities,
    numericality: { greater_than_or_equal_to: 0.0 }

  def net_equity
    return unless anticipated_income && current_assets && anticipated_expenses && current_liabilities
    anticipated_income + current_assets - anticipated_expenses - current_liabilities
  end

end

