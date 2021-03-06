class FundGrant < ActiveRecord::Base
  SEARCHABLE = [ :fund_source_name_contains, :organization_name_contains ]

  attr_accessible :fund_source_id, as: [ :default ]
  attr_accessible :fund_tier_id, as: [ :reviewer ]
  attr_readonly :organization_id, :fund_source_id

  belongs_to :organization, inverse_of: :fund_grants
  belongs_to :fund_source, inverse_of: :fund_grants
  belongs_to :fund_tier_assignment, inverse_of: :fund_grant
  has_one :fund_tier, through: :fund_tier_assignment

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
#      request.fund_request_type = proxy_association.owner.fund_source.
#        fund_request_types.upcoming.allowed_for_first.first
    end
  end
  has_many :fund_items, inverse_of: :fund_grant, dependent: :destroy
  has_many :fund_editions, through: :fund_items
  has_many :fund_queues, through: :fund_source
  has_many :fund_request_types, through: :fund_queues
  has_many :allowed_fund_request_types, through: :fund_queues, source: :fund_request_types,
    conditions: { fund_request_types: { allowed_for_first: true } } do
    def future
      where { fund_queues.submit_at.gt( Time.zone.now ) }
    end
  end
  has_many :nodes, through: :fund_items
  has_many :categories, uniq: true, through: :nodes do
    def without_activity_account
      all - proxy_association.owner.activity_account_categories
    end
  end
  has_many :requestor_memberships, through: :organization,
    source: :active_memberships, autosave: false do
      def approvers
        approver_for( proxy_association.owner.fund_source.submission_framework )
      end
      def unfulfilled_approvers
        approver_for( proxy_association.owner.fund_source.submission_framework ).
        unfulfilled_for( proxy_association.owner.fund_source.submission_framework )
      end
    end
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
  has_many :activity_account_categories, through: :activity_accounts,
    source: :category
  has_many :activity_accounts, inverse_of: :fund_grant, dependent: :destroy do
    def populate!
      proxy_association.owner.categories.without_activity_account.each do |category|
        create! category_id: category.id
        proxy_association.owner.association(:activity_account_categories).reset
      end
    end
  end

  delegate :contact_name, :contact_email, :contact_to_email, to: :fund_source
  delegate :require_requestor_recipients!, :current_registration, to: :organization
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

  before_create :adopt_fund_tier_assignment

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
  def unfulfilled_requirements(framework=nil,reset=false)
    @unfulfilled_requirements ||= Hash.new
    framework ||= fund_source.framework
    @unfulfilled_requirements[framework] = nil if reset
    @unfulfilled_requirements[framework] ||= requestor_memberships(reset).requestor.
      inject({}) { |memo, membership|
      framework.requirements.unfulfilled_by(membership).each do |requirement|
        target = membership.send( requirement.fulfiller_type.underscore.to_sym )
        memo[ target ] ||= []
        memo[ target ] << requirement
      end
      memo
    }.each { |k,v| v.uniq! }
  end

  # Fetch unfulfilled requirements for specific fulfillers
  def unfulfilled_requirements_for(*fulfillers)
    options = fulfillers.extract_options!
    fulfillers.flatten.inject({}) do |memo, fulfiller|
      unless unfulfilled_requirements(options[:framework])[ fulfiller ].blank?
        memo[ fulfiller ] = unfulfilled_requirements(options[:framework])[ fulfiller ]
      end
      memo
    end
  end

  # Adopt previously assigned fund_tier OR auto-assign to lowest available tier
  def adopt_fund_tier_assignment
    return true if fund_tier_assignment || ( self.fund_tier_assignment =
      fund_source.fund_tier_assignments.
      where( organization_id: organization_id ).first ) ||
      fund_source.fund_tiers.empty?
    create_fund_tier_assignment do |assignment|
      assignment.fund_source = fund_source
      assignment.organization = organization
      assignment.fund_tier = fund_source.fund_tiers.first
    end
  end

  def to_s
    "Fund grant to #{organization} from #{fund_source}"
  end

end

