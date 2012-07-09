class FundGrant < ActiveRecord::Base
  SEARCHABLE = [ :fund_source_name_contains, :organization_name_contains ]

  attr_accessible :fund_source_id
  attr_readonly :organization_id, :fund_source_id

  belongs_to :organization, inverse_of: :fund_grants
  belongs_to :fund_source, inverse_of: :fund_grants
  belongs_to :fund_tier, inverse_of: :fund_grants

  has_many :allowed_fund_tiers, through: :fund_source, source: :fund_tiers
  has_many :fund_allocations, through: :fund_requests do
    def except_for( fund_request )
      where { fund_request_id.not_eq( fund_request.id ) }
    end
  end
  has_many :fund_requests, inverse_of: :fund_grant, dependent: :destroy do
    # Builds a first request, inferring request type from those that are
    # allowed for the first in upcoming queues
    # * will leave fund_request_type blank if owner has no fund source
    #   from which to make the inference
    def build_first
      request = build
      return request if proxy_association.owner.fund_source.blank?
      request.fund_request_type = proxy_association.owner.fund_source.
        fund_request_types.upcoming.allowed_for_first.first
    end
  end
  has_many :fund_items, inverse_of: :fund_grant, dependent: :destroy
  has_many :fund_editions, through: :fund_items
  has_many :nodes, through: :fund_items
  has_many :categories, through: :nodes
  has_many :requestor_memberships, through: :organization,
    source: :active_memberships, autosave: false
  has_many :reviewer_memberships, through: :fund_source, source: :memberships,
    autosave: false
  has_many :requestors, through: :requestor_memberships, source: :user,
    autosave: false do
    def requestor; scoped.merge( Membership.unscoped.requestor ); end
  end
  has_many :reviewers, through: :reviewer_memberships, source: :user,
    autosave: false do
    def reviewer; scoped.merge( Membership.unscoped.reviewer ); end
  end
  has_many :activity_accounts, inverse_of: :fund_grant, dependent: :destroy
#  has_many :users, through: :organization do
#    # Retrieves users associated with a perspective for the grant
#    def for_perspective( perspective )
#      proxy_association.owner.send perspective.to_s.pluralize
#    end
#  end

  has_paper_trail class_name: 'SecureVersion'

  scope :ordered, joins { [ organization, fund_source ] }.
    order { [ fund_sources.name, organizations.last_name, organizations.first_name ] }
  scope :current, lambda { joins { fund_source }.merge( FundSource.unscoped.current ) }
  scope :closed, lambda { joins { fund_source }.merge( FundSource.unscoped.closed ) }
  scope :no_draft_fund_request, where { id.not_in(
    FundRequest.unscoped.draft.select { fund_grant_id } ) }
  scope :organization_name_contains, lambda { |name|
    joins { organization }.merge Organization.name_contains( name )
  }
  scope :fund_source_name_contains, lambda { |name|
    joins { fund_source }.merge FundSource.where( :name.like => name )
  }

  paginates_per 10

  validates :organization, presence: true
  validates :fund_source, presence: true
  validates :fund_source_id, uniqueness: { scope: :organization_id }

  delegate :contact_name, :contact_email, :contact_to_email, to: :fund_source
  delegate :require_requestor_recipients!, :current_registration, to: :organization

  def returning?
    fund_source.returning_fund_sources.
    where { |s| s.id.in( organization.fund_sources.released.select { id } ) }.
    any?
  end

  # Organization associated with this grant in requestor perspective
  def requestor; organization; end

  # Organization associated with this grant in reviewer perspective
  def reviewer; fund_source ? fund_source.organization : nil; end

  # Fetch all unfulfilled requirements
  def unfulfilled_requirements(reset=false)
    @unfulfilled_requirements = nil if reset
    @unfulfilled_requirements ||= requestor_memberships(reset).requestor.inject({}) { |memo, membership|
      fund_source.framework.requirements.unfulfilled_by(membership).each do |requirement|
        target = membership.send( requirement.fulfiller_type.underscore.to_sym )
        memo[ target ] ||= []
        memo[ target ] << requirement
      end
      memo
    }.each { |k,v| v.uniq! }
  end

  # Fetch unfulfilled requirements for specific fulfillers
  def unfulfilled_requirements_for(*fulfillers)
    fulfillers.flatten.inject({}) do |memo, fulfiller|
      unless unfulfilled_requirements[ fulfiller ].blank?
        memo[ fulfiller ] = unfulfilled_requirements[ fulfiller ]
      end
      memo
    end
  end

  def to_s
    "Fund grant to #{organization} from #{fund_source}"
  end

end

