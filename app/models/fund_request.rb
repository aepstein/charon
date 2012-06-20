class FundRequest < ActiveRecord::Base
  SEARCHABLE = [ :organization_name_contains, :fund_source_name_contains,
    :with_state, :with_review_state ]
  ACTIVE_STATES = [ :started, :tentative, :submitted, :finalized ]
  UNACTIONABLE_STATES = [ :withdrawn, :rejected ]

  attr_accessible :fund_request_type_id
  attr_accessible :reject_message, as: :rejector
  attr_accessible :fund_tier_id, as: :reviewer
  attr_readonly :fund_grant_id, :fund_request_type_id

  belongs_to :fund_tier, inverse_of: :fund_requests
  belongs_to :fund_grant, inverse_of: :fund_requests
  belongs_to :fund_queue, inverse_of: :fund_requests
  belongs_to :fund_request_type, inverse_of: :fund_requests
  belongs_to :withdrawn_by_user, class_name: 'User'

  has_many :approvals, dependent: :delete_all, as: :approvable do
    def existing
      self.reject { |approval| approval.new_record? }
    end
  end
  delegate :allowed_fund_tiers, to: :fund_grant
  has_many :fund_allocations, inverse_of: :fund_request, dependent: :destroy do
    def allocate!( fund_item, amount )
      allocation = find_or_build_by_fund_item(fund_item)
      allocation.amount = amount
      allocation.save! if allocation.changed?
    end
    def find_or_build_by_fund_item( fund_item )
      find_by_fund_item( fund_item ) or build( fund_item: fund_item )
    end
    def find_by_fund_item( fund_item )
      select { |a| a.fund_item_id == fund_item.id }.first
    end
  end
  has_many :fund_editions, dependent: :destroy, inverse_of: :fund_request do
    def nonzero?
      where { perspective.eq( FundEdition::PERSPECTIVES.first ) }.
      sum(:amount) > 0.0
    end
    def appended
      initial.not_prior_to_fund_request proxy_association.owner
    end
    def amended
      initial.prior_to_fund_request proxy_association.owner
    end
  end
  has_many :fund_items, through: :fund_editions, uniq: true,
    order: 'fund_items.position ASC' do

    # Allocate items according to specified preferences
    # * iterate through items according to specified priority
    # * limit allocations to cap if specified
    # * if request covers only some items, reduce cap by amount currently
    #   allocated to other items
    # * reset collection so changes are loaded
    def allocate!(cap = nil)
      if cap
        cap -= exclusion if exclusion
      end
      includes( :fund_editions ).roots.each do |fund_item|
          cap = allocate_fund_item! fund_item, cap
      end
      proxy_association.reset
      true
    end

    # Allocate an item and any children for which a final edition is present
    # * allocate the item if a final edition is present in the request (necessary?)
    # * apply cap if one is specified and deduct allocation from cap
    # * recursively call to each child, passing on remaining cap
    def allocate_fund_item!(fund_item, cap = nil)
      fund_edition = fund_item.fund_editions.for_request( proxy_association.owner ).last
      if fund_edition.perspective == FundEdition::PERSPECTIVES.last
        max = ( (fund_edition) ? fund_edition.amount : 0.0 )
        if cap
          min = (cap > 0.0) ? cap : 0.0
          amount = ( ( max > min ) ? min : max )
          cap -= amount
        else
          amount = max
        end
        proxy_association.owner.fund_allocations.allocate! fund_item, amount
      end
      children_of(fund_item).each { |c| cap = allocate_fund_item!(c, cap) }
      cap
    end

    # Determine amount allocated through other requests, which is the amount
    # by which to lower the effective cap for allocations to this request
    def exclusion( force_reload = false )
      @exclusion ||= proxy_association.owner.fund_grant.fund_allocations.
        except_for( proxy_association.owner ).sum( :amount )
    end

    def appended
      scoped.appended_to( proxy_association.owner )
    end

    def amended
      scoped.amended_in( proxy_association.owner )
    end

    # Return amendable fund items
    # * must be in the fund_grant from a previous submission
    # * must not already be in the request
    def amendable
      proxy_association.owner.fund_grant.fund_items.where do |q|
        q.id.not_in( proxy_association.owner.fund_editions.scoped.
          select { fund_item_id } )
      end
    end

    def for_category(category)
      self.select { |fund_item| fund_item.node.category_id == category.id }
    end
    def allocation_for_category(category)
      total = 0.0
      for_category(category).each { |i| total += i.amount }
      total
    end
  end
  has_many :users, :through => :approvals do
    # Returns users who have fulfilled unquantified approver requirements
    def fulfilled( approvers = Approver.unscoped )
      User.scoped.joins('INNER JOIN approvers').
      merge( approvers.unquantified.fulfilled_for( proxy_association.owner ).merge(
        Approval.unscoped.where( :created_at.gt => proxy_association.owner.approval_checkpoint)
      ) ).where( 'users.id = memberships.user_id' ).group('memberships.user_id', 'approvers.quantity')
    end
    # Returns users who have not fulfilled unquantified approver requirements
    def unfulfilled( approvers = Approver.unscoped )
      User.scoped.not_approved( proxy_association.owner ).joins('INNER JOIN approvers').
      merge( approvers.unquantified.unfulfilled_for( proxy_association.owner ) ).
      where( 'users.id = memberships.user_id' ).
      group('memberships.user_id', 'approvers.quantity')
    end
  end

  before_validation :set_approval_checkpoint, on: :create

  validates :fund_grant, presence: true
  validates :approval_checkpoint, timeliness: { type: :datetime }
  validates :fund_request_type, presence: true, on: :create
  validate :fund_source_must_be_same_for_grant_and_queue
  validate :fund_request_type_must_be_associated_with_fund_source,
    on: :create

  after_create :send_started_notice!

  state_machine :review_state, initial: :unreviewed, namespace: 'review' do

    state :unreviewed, :ready, :tentative

    event :approve do
      transition :unreviewed => :tentative, :if => :review_approvable?
      transition :tentative => :ready, :if => :approvals_fulfilled?
      transition :tentative => same
    end

    event :unapprove do
      transition [ :tentative, :ready ] => :unreviewed, :if => :approvals_unfulfilled?
      transition :tentative => same
    end

    event :reconsider do
      transition :ready => :unreviewed
    end

    after_transition on: :reconsider do |request, transition|
      if request.submitted_at?
        request.approvals.where { created_at > request.submitted_at }.
          delete_all
      end
    end

  end

  state_machine :initial => :started do

    state :finalized, :tentative, :released

    state :started do
      validate :no_draft_fund_request_exists, on: :create
    end

    state :withdrawn do
      validates :withdrawn_by_user, presence: true
    end

    state :rejected do
      validates :reject_message, presence: true
    end

    state :submitted do
      validates :fund_queue, presence: true
      validates :fund_queue_id, uniqueness: { scope: [ :fund_grant_id ] }
    end

    state :allocated do
      validates :review_state, inclusion: { in: %w( ready ) }
    end

    event :approve do
      transition :started => :tentative, :if => :approvable?
      transition :tentative => :submitted, :if => [ :approvals_fulfilled?, :adoptable_queue ]
      transition :tentative => :finalized, :if => :approvals_fulfilled?
      transition :tentative => same
    end

    event :unapprove do
      transition :tentative => :started, :if => :approvals_unfulfilled?
      transition :tentative => same
    end

    event :submit do
      transition :tentative => :submitted
      transition :finalized => :submitted
    end

    event :withdraw do
      transition [ :tentative, :finalized, :submitted ] => :withdrawn
    end

    event :release do
      transition :submitted => :released, :if => :releasable?
    end

    event :allocate do
      transition [ :submitted, :released ] => :allocated, :if => :releasable?
    end

    event :reject do
      transition [ :started, :tentative, :finalized, :submitted ] => :rejected
    end

    before_transition all - [ :submitted ] => :submitted,
      :do => [ :adopt_queue, :set_approval_checkpoint ]

    before_transition(
      any - [ :withdrawn, :rejected ] => [ :withdrawn, :rejected ]
    ) do |request, transition|
      if request.fund_queue
        request.fund_queue = nil
      end
    end


    after_transition all => all, :except_to => same, :do => :timestamp_state!
    after_transition :started => :tentative, :do => :deliver_required_approval_notice
    after_transition all - [ :submitted ] => :submitted,
      :do => [ :send_submitted_notice! ]
    after_transition all - [ :released ] => :released, :do => :send_released_notice!
    after_transition all - [ :withdrawn ] => :withdrawn, :do => :send_withdrawn_notice!

  end

  notifiable_events :allocated, :started, :tentative, :finalized, :rejected, :submitted,
    :released, :withdrawn, if: :require_requestor_recipients!

  has_paper_trail class_name: 'SecureVersion'

  scope :ordered, joins { [ fund_grant.fund_source, fund_grant.organization ] }.
    order( 'fund_sources.name ASC, organizations.last_name ASC, organizations.first_name ASC' )

  scope :organization_name_contains, lambda { |name|
    joins { fund_grant.organization }.merge( Organization.unscoped.
      name_contains( name ) )
  }
  scope :fund_source_name_contains, lambda { |name|
    joins { fund_grant.fund_source }.merge( FundSource.unscoped.
      where { |fund_sources| fund_sources.name =~ "%#{name}%" } )
  }
  scope :actionable, without_state( :withdrawn, :rejected )
  scope :active, lambda { with_state( ACTIVE_STATES ) }
  scope :inactive, lambda { without_state( ACTIVE_STATES ) }
  scope :prior_to, lambda { |request|
    where { created_at < request.created_at }.
    where { id != request.id }
  }
  scope :draft, with_state( :started, :tentative, :finalized )
  scope :incomplete, lambda { where("(SELECT COUNT(*) FROM fund_editions WHERE " +
    "fund_request_id = fund_requests.id AND perspective = ?) > " +
    "(SELECT COUNT(*) FROM fund_editions WHERE " +
    "fund_request_id = fund_requests.id AND perspective = ?)",
    FundEdition::PERSPECTIVES.first, FundEdition::PERSPECTIVES.last) }
  scope :duplicate, where("fund_requests.fund_grant_id IN (SELECT fund_grant_id " +
    "FROM fund_requests AS duplicates WHERE duplicates.fund_grant_id = " +
    "fund_requests.fund_grant_id AND fund_requests.id <> duplicates.id)")
  # Pull requests that have a future due date advertised that occurs on or before
  # a specified deadline
  # * use advertized due date where specified
  # * look only for due dates matching request's source and type
  scope :advertised_submit_due_by, lambda { |deadline|
    joins { fund_grant }.where { fund_grant.fund_source_id.in(
      FundQueue.unscoped.select { fund_source_id }.
      advertised_after( Time.zone.now ).advertised_before( deadline ).
      joins { fund_request_types }.
      where { fund_request_types.id.eq( fund_requests.fund_request_type_id ) }
    ) }
  }
  scope :released, lambda { with_state( :released, :allocated ) }

  paginates_per 10

  # Send notices to all fund_requests with a state
  # * Without second argument, limit to fund_requests that have not yet received such
  #   notice
  # * With second argument, limit to fund_requests that have not yet received such
  #   notice or have received such notice before specified date
  def self.notify_unnotified!( state, since = nil )
    fund_requests = FundRequest.scoped.with_state( state )
    if since.blank?
      fund_requests = fund_requests.send("no_#{state}_notice")
    else
      fund_requests = fund_requests.send("no_#{state}_notice_since", since)
    end
    fund_requests.each { |fund_request| fund_request.send("send_#{state}_notice!") }
  end

  def self.unactionable_states(format=nil)
    case format
    when :sql
      UNACTIONABLE_STATES.map { |s| connection.quote s }.join ','
    else
      UNACTIONABLE_STATES
    end
  end

  delegate :require_requestor_recipients!, :returning?, :requestors, :reviewers,
    to: :fund_grant

  # Is the request actionable?
  def actionable?; UNACTIONABLE_STATES.map(&:to_s).all? { |s| s != state }; end

  # Is the request the first actionable request?
  def first_actionable?
    fund_grant.new_record? ||
    ( actionable? &&
      !fund_grant.fund_requests.actionable.where { id != my { id } }.any? )
  end

  # Are conditions met to advance from started => tentative state?
  # * must have an edition for each item in this or another request
  # * sum of editions in this request must be non-zero
  def approvable?
    fund_grant.fund_items.where( 'fund_items.id NOT IN ' +
      '(SELECT fund_item_id FROM fund_editions)' ).empty? && fund_editions.nonzero?
  end

  # Are conditions met to advanec from unreviewed => tentative review state?
  # * must have a review for each review state
  def review_approvable?
    fund_editions.where( perspective: FundEdition::PERSPECTIVES.first ).count ==
    fund_editions.where( perspective: FundEdition::PERSPECTIVES.last ).count
  end

  # Are there any approval criteria that have not been fulfilled for current
  # tentative status?
  def approvals_fulfilled?; Approver.unfulfilled_for( self ).length == 0; end

  # Are there any approval criteria that have been fulfilled for current
  # tentative status?
  def approvals_unfulfilled?; Approver.fulfilled_for( self ).length == 0; end

  # Sets approval checkpoint to current time
  def set_approval_checkpoint; self.approval_checkpoint = Time.zone.now; end

  # Returns the closest future queue
  def adoptable_queue; fund_grant.fund_source.fund_queues.active; end

  # Return best queue to display for request
  # * assigned queue, if applicable
  # * adoptable queue, if available
  # * nil otherwise
  def target_queue
    return fund_queue if fund_queue
    return adoptable_queue if adoptable_queue
    nil
  end

  delegate :contact_name, :contact_email, :contact_to_email, to: :fund_grant

  # Is the request ready for release?
  # * based on status of review state machine
  def releasable?; review_state? :ready; end

  # What is the perspective of approvers this request is waiting on
  def approver_perspective
    return FundEdition::PERSPECTIVES.last if review_state? :tentative
    FundEdition::PERSPECTIVES.first
  end

  # What fund request types are allowed for this request?
  def allowed_fund_request_types(upcoming_only=false)
    out = fund_grant.fund_source.fund_request_types
    out = out.upcoming if upcoming_only
    out = out.allowed_for_first if first_actionable?
    out
  end

  def to_s
    return super if fund_grant.blank?
    "Request of #{fund_grant.organization} from #{fund_grant.fund_source}"
  end

  protected

  def fund_source_must_be_same_for_grant_and_queue
    return if fund_grant.blank? || fund_queue.blank?
    if fund_grant.fund_source != fund_queue.fund_source
      errors.add :fund_queue, " does not have the same fund source as the associated fund grant."
    end
  end

  def fund_request_type_must_be_associated_with_fund_source
    return unless fund_request_type && fund_grant
    if !allowed_fund_request_types.include? fund_request_type
      errors.add :fund_request_type, " is not allowed"
    end
  end

  def no_draft_fund_request_exists
    return unless fund_grant
    unless fund_grant.new_record? || fund_grant.fund_requests.draft.empty?
      errors.add :fund_grant, " already has another request in a draft state"
    end
  end

  # Assigns this request to the next future queue for processing
  def adopt_queue
    self.fund_queue ||= adoptable_queue
  end

  # Timestamp state change if appropriate
  def timestamp_state!
    update_attribute( "#{state}_at", Time.zone.now ) if has_attribute? "#{state}_at"
  end

  # Delivers approval required notice to each user who must approve the request
  def deliver_required_approval_notice
    users.unfulfilled.each do |user|
      approval = Approval.new
      approval.user = user
      approval.approvable = self
      ApprovalMailer.fund_request_notice(approval).deliver
    end
  end

end

