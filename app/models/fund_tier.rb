class FundTier < ActiveRecord::Base
  attr_accessible :maximum_allocation, as: [ :default, :admin ]
  attr_readonly :organization_id

  has_and_belongs_to_many :fund_sources
  has_many :fund_requests, inverse_of: :fund_tier, dependent: :nullify
  has_many :fund_tier_assignments, inverse_of: :fund_tier, dependent: :destroy
  has_many :fund_grants, through: :fund_tier_assignments

  belongs_to :organization, inverse_of: :fund_tiers

  default_scope order { [ organization_id, maximum_allocation ] }

  validates :organization, presence: true
  validates :maximum_allocation, presence: true,
    uniqueness: { scope: :organization_id },
    numericality: { greater_than_or_equal_to: 0.0 }

  def to_s; maximum_allocation? ? maximum_allocation.currencify : super; end
end

