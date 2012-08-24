class FundTierAssignment < ActiveRecord::Base
  SEARCHABLE = [ :organization_name_contains ]

  attr_accessible :organization_name, :fund_tier_id
  attr_readonly :fund_source_id, :organization_id

  belongs_to :fund_source, inverse_of: :fund_tier_assignments
  belongs_to :organization, inverse_of: :fund_tier_assignments
  belongs_to :fund_tier, inverse_of: :fund_tier_assignments

  has_one :fund_grant, inverse_of: :fund_tier_assignment, dependent: :nullify

  validates :fund_source, presence: true, on: :create
  validates :organization, presence: true, on: :create
  validates :organization_id, uniqueness: { scope: :fund_source_id }, on: :create
  validates :fund_tier, presence: true,
    inclusion: { in: lambda { |a| a.fund_source.fund_tiers },
      if: :fund_source }

  scope :organization_name_contains, lambda { |k|
    where( organization_id: Organization.name_contains(k) ) }
  scope :ordered, lambda { joins { organization }.
    order { [ organizations.last_name, organizations.first_name ] } }

  before_create :adopt_fund_grant

  def adopt_fund_grant
    return true if fund_grant || ( self.fund_grant = fund_source.fund_grants.
      where( organization_id: organization_id ).first )
    build_fund_grant
    fund_grant.organization = organization
  end

  include OrganizationNameLookup

  def to_s
    return super() unless fund_tier && fund_tier.maximum_allocation?
    fund_tier.to_s
  end

end

