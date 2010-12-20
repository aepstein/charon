class Request < ActiveRecord::Base
  default_scope includes( :organization, :basis ).
    order( 'bases.name ASC, organizations.last_name ASC, organizations.first_name ASC' )

  belongs_to :basis
  has_many :approvals, :dependent => :delete_all, :as => :approvable do
    def existing
      self.reject { |approval| approval.new_record? }
    end
  end
  has_many :users, :through => :approvals do
    def for_perspective( perspective )
      ( Membership.includes(:user).
          where( :organization_id => proxy_owner.send(perspective).id ) &
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
  has_many :items, :dependent => :destroy, :order => 'items.position ASC' do
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
  belongs_to :organization

  scope :organization_name_contains, lambda { |name|
    scoped & Organization.name_contains( name )
  }
  scope :basis_name_contains, lambda { |name|
    scoped & Basis.where( :name.like => name )
  }
  scope :incomplete_for_perspective, lambda { |perspective|
    where( "requests.id IN (SELECT request_id FROM items LEFT JOIN " +
        "editions ON items.id = editions.item_id AND editions.perspective = ? " +
        "WHERE items.request_id = requests.id AND editions.id IS NULL)", perspective )
  }

  search_methods :organization_name_contains, :basis_name_contains

  delegate :structure, :to => :basis
  delegate :framework, :to => :basis
  delegate :nodes, :to => :structure
  delegate :contact_name, :to => :basis
  delegate :contact_email, :to => :basis

  before_validation :set_approval_checkpoint, :on => :create

  validates_presence_of :organization
  validates_datetime :approval_checkpoint
  validates_presence_of :basis

  def must_have_open_basis
    errors.add( :basis_id, 'must be an open basis.' ) unless basis.open?
  end

  attr_readonly :basis_id

  include AASM
  aasm_column :status
  aasm_initial_state :started
  aasm_state :started
  aasm_state :completed, :after_enter => :deliver_required_approval_notice
  aasm_state :submitted, :enter => :reset_approval_checkpoint
  aasm_state :accepted, :after_enter => :set_accepted_at
  aasm_state :reviewed
  aasm_state :certified, :enter => :reset_approval_checkpoint
  aasm_state :released, :after_enter => [:deliver_release_notice, :set_released_at]

  aasm_event :accept do
    transitions :to => :accepted, :from => :submitted
  end
  aasm_event :submit do
    transitions :to => :submitted, :from => :completed
  end
  aasm_event :approve do
    transitions :to => :completed, :from => :started, :guard => :approvable?
    transitions :to => :submitted, :from => :completed, :guard => :approvals_fulfilled?
    transitions :to => :reviewed, :from => :accepted, :guard => :approvable?
    transitions :to => :certified, :from => :reviewed, :guard => :approvals_fulfilled?
  end
  aasm_event :unapprove do
    transitions :to => :started, :from => :completed, :guard => :approvals_unfulfilled?
    transitions :to => :completed, :from => :submitted
    transitions :to => :accepted, :from => :reviewed, :guard => :approvals_unfulfilled?
    transitions :to => :reviewed, :from => :certified
  end
  aasm_event :release do
    transitions :to => :released, :from => :certified
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

  def deliver_release_notice
    RequestMailer.release_notice(self).deliver
  end

  def set_accepted_at
    self.accepted_at = Time.zone.now
  end

  def set_released_at
    self.released_at = Time.zone.now
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
    self.approval_checkpoint = approvals.existing.last.created_at
  end

  def contact_to_email
    "#{contact_name} <#{contact_email}>"
  end

  def self.aasm_state_names
    Request.aasm_states.map { |s| s.name.to_s }
  end

  def to_s
    "Request of #{organization} from #{basis}"
  end
end

