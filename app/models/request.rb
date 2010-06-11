class Request < ActiveRecord::Base
  default_scope :include => [ :organization, :basis ],
    :order => 'bases.name ASC, organizations.last_name ASC, organizations.first_name ASC'

  belongs_to :basis
  has_many :approvals, :dependent => :delete_all, :as => :approvable do
    def existing
      self.reject { |approval| approval.new_record? }
    end
  end
  has_many :users, :through => :approvals do
    def for_perspective( perspective )
      User.memberships_active.memberships_role_name_like_any( Role::REQUESTOR ).memberships_organization_id_equals( proxy_owner.send(perspective).id )
    end
    def fulfilled( approvers = Approver )
      approvers_to_users( approvers.fulfilled_for( proxy_owner ) ) & after_checkpoint
    end
    def unfulfilled( approvers = Approver )
      approvers_to_users( approvers.unfulfilled_for( proxy_owner ) ) - all
    end
    protected
    def after_checkpoint
      all( :conditions => ['approvals.created_at > ?', proxy_owner.approval_checkpoint] )
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
      User.all( :joins => [:memberships], :conditions => approvers_fragments.join(' OR ') +
        " AND memberships.active = #{connection.quote true}" ) - self
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

  named_scope :organization_name_like, lambda { |name|
    { :conditions => ['organizations.last_name LIKE ? OR organizations.first_name LIKE ?', "%#{name}%", "%#{name}%" ] }
  }
  named_scope :basis_name_like, lambda { |name|
    { :conditions => ['bases.name LIKE ?', "%#{name}%"] }
  }
  named_scope :incomplete_for_perspective, lambda { |perspective|
    { :conditions => [ "requests.id IN (SELECT request_id FROM items LEFT JOIN " +
        "editions ON items.id = editions.item_id AND editions.perspective = ? " +
        "WHERE items.request_id = requests.id AND editions.id IS NULL)", perspective ] }
  }

  delegate :structure, :to => :basis
  delegate :framework, :to => :basis
  delegate :nodes, :to => :structure
  delegate :contact_name, :to => :basis
  delegate :contact_email, :to => :basis

  before_validation_on_create :set_approval_checkpoint

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

  def approvable?
    case status
    when 'started'
      !Request.incomplete_for_perspective('requestor').include?(self)
    else
      !Request.incomplete_for_perspective('reviewer').include?(self)
    end
  end

  def deliver_required_approval_notice
    needed_approvals = users.unfulfilled(Approver.quantity_null).map { |u| approvals.build( :user => u )  }
    needed_approvals.each do |approval|
      ApprovalMailer.deliver_request_notice(approval)
    end
  end

  def deliver_release_notice
    RequestMailer.deliver_release_notice(self)
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

  def self.aasm_state_names
    Request.aasm_states.map { |s| s.name.to_s }
  end

  def to_s
    "Request of #{organization} from #{basis}"
  end
end

