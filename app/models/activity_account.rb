class ActivityAccount < ActiveRecord::Base
  attr_accessible :comments, :category_id
  attr_readonly :fund_grant_id

  belongs_to :fund_grant, inverse_of: :activity_accounts
  belongs_to :category, inverse_of: :activity_accounts

  has_many :adjustments, dependent: :destroy, class_name: 'AccountAdjustment',
    inverse_of: :activity_account
  has_many :allocations, through: :fund_grant, source: :fund_allocations,
    conditions: Proc.new {
      { fund_item_id: FundItem.with_category( category ) }
    }
  has_one :organization, through: :fund_grant
  has_one :fund_source, through: :fund_grant

  scope :organization_id_equals, lambda { |id|
    joins(:fund_grant).where { fund_grants.organization_id.eq( id ) }
  }
  scope :organization_id_in, lambda { |ids|
    joins(:fund_grant).where { fund_grants.organization_id.in( ids ) }
  }
  scope :transactable_for, lambda { |activity_account|
    organization_id_in( [ activity_account.organization.id,
      activity_account.fund_source.organization.id ] ).
    where { id.not_eq( activity_account.id ) }
  }
  scope :with_balances, select {
    sum_allocations_sql = FundAllocation.unscoped.joins { fund_item.node }.select { SUM(amount) }.
      where { fund_items.fund_grant_id.eq(activity_accounts.fund_grant_id) &
       nodes.category_id.eq(activity_accounts.category_id) }.to_sql
    sum_adjustments_sql = AccountAdjustment.unscoped.select { SUM(amount) }.
      where { activity_account_id.eq( activity_accounts.id ) }.to_sql
    [ `\`activity_accounts\`.*`,
      `IFNULL( (#{sum_allocations_sql}), 0.0 )`.as(sum_allocations),
      `IFNULL( (#{sum_adjustments_sql}), 0.0 )`.as(sum_adjustments) ]
  }
  scope :current, joins { fund_grant }.merge( FundGrant.unscoped.current )
  scope :closed, joins { fund_grant }.merge( FundGrant.unscoped.closed )

  validates :fund_grant, presence: true
  validates :category, presence: true
  validates :fund_grant_id, uniqueness: { scope: [ :category_id ] }

  # If sum of allocations is cached, use it.  Otherwise, calculate
  def sum_allocations
    attributes['sum_allocations'] ? attributes['sum_allocations'] : allocations.sum(:amount)
  end

  # If sum of adjustments is cached, use it.  Otherwise, calculate.
  def sum_adjustments
    attributes['sum_adjustments'] ? attributes['sum_adjustments'] : adjustments.sum(:amount)
  end

  # Total available funds for activity account is allocation plus manual adjustments
  def sum_available; sum_allocations + sum_adjustments; end

end

