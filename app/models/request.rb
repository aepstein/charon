class Request < ActiveRecord::Base
  include Notifiable

  attr_readonly :basis_id

  belongs_to :withdrawn_by_user, :class_name => 'User'
  belongs_to :basis, :inverse_of => :requests
  belongs_to :organization, :inverse_of => :requests
  has_many :approvals, :dependent => :delete_all, :as => :approvable do
    def existing
      self.reject { |approval| approval.new_record? }
    end
  end
  has_many :users, :through => :approvals do
    def for_perspective( perspective )
      ( Membership.includes(:user).
          where( :active => true, :organization_id => proxy_owner.send(perspective).id ) &
          Role.where( :name.in => Role::REQUESTOR ) ).map(&:user)
    end
    def fulfilled( approvers = Approver )
      approvers_to_users( approvers.fulfilled_for( proxy_owner ) ) & after_checkpoint
    end
    def unfulfilled( approvers = Approver )
      approvers_to_users( approvers.unfulfilled_for( proxy_owner ) ) - all
    end
    def required_for_status( status )
      approvers_to_users( Approver.where( :framework_id => proxy_owner.basis.framework_id,
        :status => status, :quantity => nil ) )
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
  has_many :items, :dependent => :destroy, :order => 'items.position ASC',
    :inverse_of => :request do
    def children_of(parent_item)
      self.select { |item| item.parent_id == parent_item.id }
    end
    def root
      self.select { |item| item.parent_id.nil? }
    end
    def for_category(category)
      self.select { |item| item.node.category_id == category.id }
    end
    def allocation_for_category(category)
      total = 0.0
      for_category(category).each { |i| total += i.amount }
      total
    end
    def initialize_next_edition
      root.each { |item| item.initialize_next_edition }
    end
    def allocate(cap = nil)
      root.each do |item|
        cap = allocate_item(item, cap)
      end
    end
    def allocate_item(item, cap = nil)
      edition = item.editions.for_perspective('reviewer')
      max = ( (edition) ? edition.amount : 0.0 )
      if cap
        min = (cap > 0.0) ? cap : 0.0
        item.amount = ( ( max > min ) ? min : max )
        cap -= item.amount
      else
        item.amount = max
      end
      item.save if item.changed?
      children_of(item).each { |c| cap = allocate_item(c, cap) }
      return nil unless cap
      cap
    end
  end
  has_many :editions, :through => :items

  before_validation :set_approval_checkpoint, :on => :create

  validates :organization, :presence => true
  validates :approval_checkpoint, :timeliness => { :type => :datetime }
  validates :basis, :presence => true

  state_machine :status, :initial => :started do

    state :started, :completed, :submitted, :accepted, :reviewed, :certified,
      :released

    state :withdrawn do
      validates :withdrawn_by_user, :presence => true
    end

    state :rejected do
      validates :reject_message, :presence => true
    end

    event :approve do
      transition :started => :completed, :if => :approvable?
      transition :accepted => :reviewed, :if => :approvable?
      transition :completed => :submitted, :if => :approvals_fulfilled?
      transition :reviewed => :certified, :if => :approvals_fulfilled?
      transition [ :completed, :reviewed ] => same
    end

    event :unapprove do
      transition :completed => :started, :if => :approvals_unfulfilled?
      transition :reviewed => :accepted, :if => :approvals_unfulfilled?
      transition [ :completed, :reviewed ] => same
    end

    event :submit do
      transition :completed => :submitted
    end

    event :withdraw do
      transition [ :completed, :submitted ] => :withdrawn
    end

    event :accept do
      transition :submitted => :accepted
    end

    event :certify do
      transition :reviewed => :certified
    end

    event :release do
      transition :certified => :released
    end

    event :reject do
      transition [ :started, :completed, :submitted ] => :rejected
    end

    after_transition :started => :completed, :do => :deliver_required_approval_notice
    after_transition :accepted => :reviewed, :do => :deliver_required_approval_notice
    after_transition :completed => :submitted,
      :do => [ :reset_approval_checkpoint, :send_submitted_notice! ]
    after_transition :reviewed => :certified, :do => :reset_approval_checkpoint
    after_transition :certified => :released, :do => :send_released_notice!
    after_transition all - [ :withdrawn ] => :withdrawn, :do => :send_withdrawn_notice!
    after_transition :except_to => same, :do => :timestamp_status!

  end

  notifiable_events :started, :completed, :submitted, :rejected, :accepted,
    :released, :withdrawn

  has_paper_trail :class_name => 'SecureVersion'

  default_scope includes( :organization, :basis ).
    order( 'bases.name ASC, organizations.last_name ASC, organizations.first_name ASC' )

  scope :organization_name_contains, lambda { |name|
    scoped.merge Organization.name_contains( name )
  }
  scope :basis_name_contains, lambda { |name|
    scoped.merge Basis.where( :name.like => name )
  }
  scope :incomplete_for_perspective, lambda { |perspective|
    where( "requests.id IN (SELECT request_id FROM items LEFT JOIN " +
        "editions ON items.id = editions.item_id AND editions.perspective = ? " +
        "WHERE items.request_id = requests.id AND editions.id IS NULL)", perspective )
  }
  scope :duplicate, where("requests.basis_id IN (SELECT basis_id FROM requests " +
    "AS duplicates WHERE duplicates.organization_id = requests.organization_id " +
    "AND requests.id <> duplicates.id)")

  search_methods :organization_name_contains, :basis_name_contains

  # Send notices to all requests with a status
  # * Without second argument, limit to requests that have not yet received such
  #   notice
  # * With second argument, limit to requests that have not yet received such
  #   notice or have received such notice before specified date
  def self.notify_unnotified!( status, since = nil )
    requests = Request.scoped.with_status( status )
    if since.blank?
      requests = requests.send("no_#{status}_notice")
    else
      requests = requests.send("no_#{status}_notice_since", since)
    end
    requests.each { |request| request.send("send_#{status}_notice!") }
  end

  alias :requestor :organization

  def reviewer; basis ? basis.organization : nil; end

  def perspective_for( fulfiller )
    case fulfiller.class.to_s.to_sym
    when :User
      return 'requestor' if fulfiller.roles.requestor_in? organization
      return 'reviewer' if basis && fulfiller.roles.reviewer_in?( basis.organization )
    when :Organization
      return 'requestor' if fulfiller == organization
      return 'reviewer' if basis && ( fulfiller == basis.organization )
    else
      raise ArgumentError, "argument cannot be of class #{fulfiller.class}"
    end
    nil
  end

  def unfulfilled_requirements_for( fulfiller )
    perspective = perspective_for( fulfiller )
    return [] unless perspective && basis
    case fulfiller.class.to_s.to_sym
    when :User
      basis.framework.requirements.unfulfilled_for( fulfiller, perspective,
        fulfiller.roles.ids_in_perspective( send(perspective), perspective ) )
    when :Organization
      basis.framework.requirements.unfulfilled_for( fulfiller, perspective, [] )
    else
      raise ArgumentError, "argument cannot be of class #{fulfiller.class}"
    end
  end

  def approvable?
    case status
    when 'started'
      !Request.incomplete_for_perspective('requestor').include?(self)
    else
      !Request.incomplete_for_perspective('reviewer').include?(self)
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

  def contact_name; basis ? basis.contact_name : nil; end

  def contact_email; basis ? basis.contact_email : nil; end

  def contact_to_email
    return nil unless basis
    "#{basis.contact_name} <#{basis.contact_email}>"
  end

  def self.aasm_state_names
    [ :started, :completed, :submitted, :accepted, :reviewed, :certified,
      :released, :rejected, :withdrawn ]
  end

  def to_s
    "Request of #{organization} from #{basis}"
  end

  protected

  def timestamp_status!
    update_attribute( "#{status}_at", Time.zone.now ) if has_attribute? "#{status}_at"
  end

  def deliver_required_approval_notice
    needed_approvals = users.unfulfilled(Approver.where( :quantity => nil )).map do |u|
      a = Approval.new( :user => u )
      a.approvable = self
      a
    end
    needed_approvals.each do |approval|
      ApprovalMailer.request_notice(approval).deliver
    end
  end

end

