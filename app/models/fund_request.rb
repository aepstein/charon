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
    def allocate!(cap = nil)
      if cap
        exclusion = where( :id.not_in => proxy_owner.fund_editions.final.
          map( &:fund_item_id ) ).sum( :amount )
        cap -= exclusion if exclusion
      end
      includes( :fund_editions ).where(:parent_id => nil).each do |fund_item|
          cap = allocate_fund_item! fund_item, cap
      end
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
      return nil unless cap
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
    def for_perspective( perspective )
      ( Membership.includes(:user).where( :active => true,
        :organization_id => proxy_owner.send(perspective).id ).
        merge( Role.where( :name.in => Role::REQUESTOR ) ) ).map(&:user)
    end
    def fulfilled( approvers = Approver )
      approvers_to_users( approvers.fulfilled_for( proxy_owner ) ) & after_checkpoint
    end
    def unfulfilled( approvers = Approver )
      approvers_to_users( approvers.unfulfilled_for( proxy_owner ) ) - all
    end
    def required_for_state( state )
      approvers_to_users( Approver.where( :framework_id => proxy_owner.
        fund_grant.fund_source.framework_id, :state => state,
        :quantity => nil ) )
    end
    protected
    def after_checkpoint
      where( 'approvals.created_at > ?', proxy_owner.approval_checkpoint )
    end
    def approvers_to_users(approvers)
      approvers_organized = approvers.inject({}) do |memo, approver|
        memo[approver.perspective] ||= Array.new
        memo[approver.perspective] << approver.role_id
        memo
      end
      approvers_fragments = Array.new
      approvers_organized.each do |perspective, role_ids|
        approvers_fragments << ( "( memberships.organization_id = #{proxy_owner.send(perspective).id} " +
          "AND memberships.role_id IN (#{role_ids.join(',')}) )" )
      end
      return Array.new if approvers.length == 0
      User.joins( :memberships).where( approvers_fragments.join(' OR ') +
        " AND memberships.active = #{connection.quote true}" ).all - self
    end
  end

  accepts_nested_attributes_for :fund_grant

  before_validation :set_approval_checkpoint, :on => :create

  validates :fund_grant, :presence => true
  validates :approval_checkpoint, :timeliness => { :type => :datetime }
  validate :fund_source_must_be_same_for_grant_and_queue

  state_machine :review_state, :initial => :unreviewed,
    :namespace => 'review' do

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

  state_machine :request_state, :initial => :started do

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
    end

    event :withdraw do
      transition [ :tentative, :finalized ] => :withdrawn
    end

    event :release do
      transition :submitted => :released, :if => :releasable?
    end

    event :reject do
      transition [ :finalized, :submitted ] => :rejected
    end

    before_transition all - [ :submitted ] => :submitted, :do => :adopt_queue

    after_transition :started => :tentative, :do => :deliver_required_approval_notice
    after_transition all - [ :submitted ] => :submitted,
      :do => [ :reset_approval_checkpoint, :send_submitted_notice! ]
    after_transition :reviewed => :certified, :do => :reset_approval_checkpoint
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
    scoped.merge Organization.name_contains( name )
  }
  scope :fund_source_name_contains, lambda { |name|
    scoped.merge FundSource.where( :name.like => name )
  }
  scope :incomplete, lambda { where("(SELECT COUNT(*) FROM fund_editions WHERE " +
    "fund_request_id = fund_requests.id AND perspective = ?) > " +
    "(SELECT COUNT(*) FROM fund_editions WHERE " +
    "fund_request_id = fund_requests.id AND perspective = ?)",
    FundEdition::PERSPECTIVES.first, FundEdition::PERSPECTIVES.last) }
  scope :duplicate, where("fund_requests.fund_grant_id IN (SELECT fund_grant_id FROM fund_requests " +
    "AS duplicates WHERE duplicates.fund_grant_id = fund_requests.fund_grant_id " +
    "AND fund_requests.id <> duplicates.id)")

  search_methods :organization_name_contains, :fund_source_name_contains

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

  # Organization associated with this request in requestor perspective
  def requestor
    fund_grant ? fund_grant.organization : nil
  end

  # Organization associated with this request in reviewer perspective
  def reviewer
    fund_grant && fund_grant.fund_source ? fund_grant.organization : nil
  end

  def perspective_for( fulfiller )
    case fulfiller.class.to_s.to_sym
    when :User
      return 'requestor' if fulfiller.roles.requestor_in? requestor
      return 'reviewer' if fulfiller.roles.reviewer_in? reviewer
    when :Organization
      return 'requestor' if fulfiller == requestor
      return 'reviewer' if fulfiller == reviewer
    else
      raise ArgumentError, "argument cannot be of class #{fulfiller.class}"
    end
    nil
  end

  # What requirements must the user or organization fulfill in order to have
  # privileges for this request?
  # * fulfiller is a user or organization
  def unfulfilled_requirements_for( fulfiller )
    perspective = perspective_for( fulfiller )
    return [] unless perspective && fund_grant && fund_grant.fund_source
    case fulfiller.class.to_s.to_sym
  when :User
      fund_grant.fund_source.framework.requirements.unfulfilled_for( fulfiller, perspective,
        fulfiller.roles.ids_in_perspective( send(perspective), perspective ) )
    when :Organization
      fund_grant.fund_source.framework.requirements.unfulfilled_for( fulfiller, perspective, [] )
    else
      raise ArgumentError, "argument cannot be of class #{fulfiller.class}"
    end
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

  def approvals_fulfilled?
    users.unfulfilled.length == 0
  end

  def approvals_unfulfilled?
    users.fulfilled.length == 0
  end

  def set_approval_checkpoint
    self.approval_checkpoint = Time.zone.now
  end

  def reset_approval_checkpoint
    return if approvals.existing.last.nil?
    update_attribute :approval_checkpoint, approvals.existing.last.created_at
  end

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
    return FundEdition::PERSPECTIVES.first if request_state? :tentative
    return FundEdition::PERSPECTIVES.last if review_state? :tentative
  end

  def self.aasm_state_names
    [ :started, :completed, :submitted, :accepted, :reviewed, :certified,
      :released, :rejected, :withdrawn ]
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

  def timestamp_state!
    update_attribute( "#{state}_at", Time.zone.now ) if has_attribute? "#{state}_at"
  end

  def deliver_required_approval_notice
    needed_approvals = users.unfulfilled(Approver.where( :quantity => nil )).map do |u|
      a = Approval.new( :user => u )
      a.approvable = self
      a
    end
    needed_approvals.each do |approval|
      ApprovalMailer.fund_request_notice(approval).deliver
    end
  end

end

