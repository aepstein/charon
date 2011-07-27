class FundRequest < ActiveRecord::Base
  include Notifiable

  attr_accessible :fund_grant_attributes
  attr_readonly :fund_grant_id

  belongs_to :fund_grant, :inverse_of => :fund_requests
  belongs_to :fund_queue, :inverse_of => :fund_requests
  belongs_to :withdrawn_by_user, :class_name => 'User'

  has_many :approvals, :dependent => :delete_all, :as => :approvable do
    def existing
      self.reject { |approval| approval.new_record? }
    end
  end
  has_many :fund_editions, :dependent => :destroy, :inverse_of => :fund_request
  has_many :fund_items, :through => :fund_grant, :order => 'fund_items.position ASC' do

    # Allocate items according to specified preferences
    # * iterate through items according to specified priority
    # * limit allocations to cap if specified
    # * if request covers only some items, reduce cap by amount currently
    #   allocated to other items
    # * reset collection so changes are loaded
    def allocate!(cap = nil)
      if cap
        exclusion = proxy_owner.fund_grant.fund_items.where(
            :id.not_in => proxy_owner.fund_editions.final.map( &:fund_item_id )
          ).sum( :amount )
        cap -= exclusion if exclusion
      end
      includes( :fund_editions ).roots.each do |fund_item|
          cap = allocate_fund_item! fund_item, cap
      end
      reset
    end

    # Allocate an item and any children for which a final edition is present
    # * allocate the item if a final edition is present in the request
    # * apply cap if one is specified and deduct allocation from cap
    # * recursively call to each child, passing on remaining cap
    def allocate_fund_item!(fund_item, cap = nil)
      fund_edition = fund_item.fund_editions.for_request( proxy_owner ).last
      if fund_edition.perspective == FundEdition::PERSPECTIVES.last
        max = ( (fund_edition) ? fund_edition.amount : 0.0 )
        if cap
          min = (cap > 0.0) ? cap : 0.0
          fund_item.amount = ( ( max > min ) ? min : max )
          cap -= fund_item.amount
        else
          fund_item.amount = max
        end
        fund_item.save! if fund_item.changed?
      end
      children_of(fund_item).each { |c| cap = allocate_fund_item!(c, cap) }
      cap
    end

    def children_of(parent_fund_item)
      self.select { |fund_item| fund_item.parent_id == parent_fund_item.id }
    end
    def root
      self.select { |fund_item| fund_item.parent_id.nil? }
    end
    def for_category(category)
      self.select { |fund_item| fund_item.node.category_id == category.id }
    end
    def allocation_for_category(category)
      total = 0.0
      for_category(category).each { |i| total += i.amount }
      total
    end
    def initialize_next_fund_edition
      root.each { |fund_item| fund_item.initialize_next_fund_edition }
    end
  end
  has_many :users, :through => :approvals do
    # Returns users who have fulfilled unquantified approver requirements
    def fulfilled( approvers = Approver.unscoped )
      User.scoped.joins('INNER JOIN approvers').
      merge( approvers.unquantified.fulfilled_for( proxy_owner ).merge(
        Approval.unscoped.where( :created_at.gt => proxy_owner.approval_checkpoint)
      ) ).where( 'users.id = memberships.user_id' ).group('memberships.user_id', 'approvers.quantity')
    end
    # Returns users who have not fulfilled unquantified approver requirements
    def unfulfilled( approvers = Approver.unscoped )
      User.scoped.not_approved( proxy_owner ).joins('INNER JOIN approvers').
      merge( approvers.unquantified.unfulfilled_for( proxy_owner ) ).
      where( 'users.id = memberships.user_id' ).group('memberships.user_id', 'approvers.quantity')
    end
  end

  before_validation :set_approval_checkpoint, :on => :create

  validates :fund_grant, :presence => true
  validates :approval_checkpoint, :timeliness => { :type => :datetime }
  validate :fund_source_must_be_same_for_grant_and_queue

  state_machine :review_state, :initial => :unreviewed, :namespace => 'review' do

    state :unreviewed, :tentative, :ready

    event :approve do
      transition :assigned => :tentative, :if => :approvable?
      transition :tentative => :ready, :if => :approvals_fulfilled?
      transition :tentative => same
    end

    event :unapprove do
      transition :tentative => :assigned, :if => :approvals_unfulfilled?
      transition :tentative => same
    end

    after_transition :assigned => :tentative, :do => :deliver_required_approval_notice
  end

  state_machine :initial => :started do

    state :finalized, :released, :started, :tentative

    state :withdrawn do
      validates :withdrawn_by_user, :presence => true
    end

    state :rejected do
      validates :reject_message, :presence => true
    end

    state :submitted do
      validates :fund_queue, :presence => true
      validates :fund_queue_id, :uniqueness => { :scope => [ :fund_grant_id ] }
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

    event :reject do
      transition [ :finalized, :submitted ] => :rejected
    end

    before_transition all - [ :submitted ] => :submitted,
      :do => [ :adopt_queue, :set_approval_checkpoint ]

    after_transition :started => :tentative, :do => :deliver_required_approval_notice
    after_transition all - [ :submitted ] => :submitted,
      :do => [ :send_submitted_notice! ]
    after_transition all - [ :released ] => :released, :do => :send_released_notice!
    after_transition all - [ :withdrawn ] => :withdrawn, :do => :send_withdrawn_notice!
    after_transition :except_to => same, :do => :timestamp_state!

  end

  notifiable_events :started, :completed, :submitted, :rejected, :accepted,
    :released, :withdrawn

  has_paper_trail :class_name => 'SecureVersion'

  default_scope includes( :fund_grant => [ :organization, :fund_source ] ).
    order( 'fund_sources.name ASC, organizations.last_name ASC, organizations.first_name ASC' )

  scope :organization_name_contains, lambda { |name|
    scoped.joins { ~fund_grant.organization }.merge( Organization.name_contains name )
  }
  scope :fund_source_name_contains, lambda { |name|
    scoped.joins { ~fund_grant.fund_source }.merge( FundSource.
      where { |fund_sources| fund_sources.name =~ "%#{name}%" } )
  }
  scope :incomplete, lambda { where("(SELECT COUNT(*) FROM fund_editions WHERE " +
    "fund_request_id = fund_requests.id AND perspective = ?) > " +
    "(SELECT COUNT(*) FROM fund_editions WHERE " +
    "fund_request_id = fund_requests.id AND perspective = ?)",
    FundEdition::PERSPECTIVES.first, FundEdition::PERSPECTIVES.last) }
  scope :duplicate, where("fund_requests.fund_grant_id IN (SELECT fund_grant_id " +
    "FROM fund_requests AS duplicates WHERE duplicates.fund_grant_id = " +
    "fund_requests.fund_grant_id AND fund_requests.id <> duplicates.id)")

  paginates_per 10
  search_methods :organization_name_contains, :fund_source_name_contains,
    :with_state

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

  # Is the request sufficiently complete to approve?
  # * for started request: an edition must exist for every grant item, but not
  #   necessarily in this request
  # * for accepted request: must have final edition for each initial edition
  #   submitted
  def approvable?
    case state
    when 'started'
      fund_grant.fund_items.where( 'fund_items.id NOT IN ' +
        '(SELECT fund_item_id FROM fund_editions)' ).empty?
    else
      fund_editions.where(:perspective => FundEdition::PERSPECTIVES.first).count ==
      fund_editions.where(:perspective => FundEdition::PERSPECTIVES.last).count
    end
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

  def contact_name; fund_grant && fund_grant.fund_source ? fund_grant.fund_source.contact_name : nil; end

  def contact_email; fund_grant && fund_grant.fund_source ? fund_grant.fund_source.contact_email : nil; end

  def contact_to_email
    return nil unless fund_grant && fund_grant.fund_source
    "#{fund_grant.fund_source.contact_name} <#{fund_grant.fund_source.contact_email}>"
  end

  # Is the request ready for release?
  # * based on status of review state machine
  def releasable?; review_state? :ready; end

  # What is the perspective of approvers this request is waiting on
  def approver_perspective
    return FundEdition::PERSPECTIVES.last if review_state? :tentative
    FundEdition::PERSPECTIVES.first
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

