class Request < ActiveRecord::Base
  ACTIONS = %w( create update destroy see approve unapprove unapprove_other accept revise review release )
  belongs_to :basis
  has_many :approvers, :through => :approvals, :source => :user do
    def empty_for_status?( status=nil )
      status ||= proxy_owner.status
      proxy_owner.framework.approvers.status(status).map { |a| actual_for(a) }.flatten.empty?
    end
    def fulfill_status?( status=nil )
      status ||= proxy_owner.status
      proxy_owner.framework.approvers.status(status).each do |approver|
        return false unless fulfill?( approver )
      end
      true
    end
    def required_for_status( status )
      approvers = proxy_owner.framework.approvers.status(status).select { |a| a.quantity.nil? }
      approvers.map { |a| potential_for(a) }.flatten.uniq
    end
    def unfulfilled_for_status( status )
      required_for_status( status ) - self
    end
    def fulfill?( approver )
      if approver.quantity
        actual_for(approver).size >= approver.quantity
      else
        ( potential_for( approver ) - actual_for( approver )  ).empty?
      end
    end
    def actual_for( approver )
      potential_for( approver ) & self.find(:all, :conditions => ['approvals.created_at > ?', proxy_owner.approval_checkpoint.utc ] )
    end
    def potential_for( approver )
      sql = case approver.perspective
      when 'requestor'
        "memberships INNER JOIN organizations_requests WHERE memberships.organization_id = " +
        "organizations_requests.organization_id AND request_id = :request_id"
      when 'reviewer'
        "memberships WHERE organization_id = :organization_id"
      end
      conditions = [
        "users.id IN (SELECT user_id FROM #{sql} AND active = :true AND role_id = :role_id)",
        { :request_id => proxy_owner.id, :role_id => approver.role_id, :true => true,
          :organization_id => proxy_owner.basis.organization_id }
      ]
      User.find( :all, :conditions => conditions )
    end
  end
  has_many :approvals, :dependent => :delete_all, :as => :approvable do
    def existing
      self.reject { |approval| approval.new_record? }
    end
  end
  has_many :items, :dependent => :destroy, :include => [ :node, :parent, :versions ], :order => 'items.position ASC' do
    def children_of(parent_item)
      self.select { |item| item.parent_id == parent_item.id }
    end
    def root
      self.select { |item| item.parent_id.nil? }
    end
    def initialize_next_version
      root.each { |item| item.initialize_next_version }
    end
    def allocate(cap = nil)
      root.each do |item|
        cap = allocate_item(item, cap)
      end
    end
    def allocate_item(item, cap = nil)
      version = item.versions.for_perspective('reviewer')
      max = (version) ? version.amount : 0.0
      if cap
        min = cap > 0.0 ? cap : 0.0
        item.amount = ( max > min ) ? min : max
      else
        item.amount = max
      end
      item.save if item.changed?
      children_of(item).each { allocate_item(c,cap) }
      return nil unless cap
      cap - item.amount
    end
  end
  has_many :versions, :through => :items
  has_and_belongs_to_many :organizations do
    def allowed?(organization)
      organization.eligible_for?(proxy_owner.framework)
    end
    def to_s
      self.join ', '
    end
  end

  named_scope :organization_like, lambda { |name|
    { :include => :organizations,
      :conditions => ['organizations.last_name LIKE ? OR organizations.first_name LIKE ?', "%#{name}%", "%#{name}%" ],
      :order => 'organizations.last_name ASC, organizations.first_name ASC' }
  }
  named_scope :basis_like, lambda { |name|
    { :include => :basis, :order => 'bases.name ASC', :conditions => ['bases.name LIKE ?', "%#{name}%"] }
  }

  delegate :structure, :to => :basis
  delegate :framework, :to => :basis
  delegate :nodes, :to => :structure
  delegate :permissions, :to => :framework
  delegate :contact_name, :to => :basis
  delegate :contact_email, :to => :basis

  before_validation_on_create :set_approval_checkpoint

  validate :must_have_eligible_organizations
  validates_datetime :approval_checkpoint

  def must_have_open_basis
    errors.add( :basis_id, 'must be an open basis.' ) unless basis.open?
  end
  def must_have_eligible_organizations
    if organizations.empty?
      errors.add_to_base( "Must have at least one organization associated with request." )
    end
    organizations.each do |organization|
      unless organizations.allowed?(organization)
        errors.add_to_base( "#{organization} is not currently eligible to participate in request." )
      end
    end
  end

  attr_readonly :basis_id

  include AASM
  aasm_column :status
  aasm_initial_state :started
  aasm_state :started
  aasm_state :completed, :after_enter => :deliver_required_approval_notice
  aasm_state :submitted, :enter => :reset_approval_checkpoint
  aasm_state :accepted
  aasm_state :reviewed
  aasm_state :certified, :enter => :reset_approval_checkpoint
  aasm_state :released

  aasm_event :accept do
    transitions :to => :accepted, :from => :submitted
#    accepted_at = DateTime.now
  end
  aasm_event :submit do
    transitions :to => :submitted, :from => :completed
  end
  aasm_event :approve do
    transitions :to => :completed, :from => :started
    transitions :to => :submitted, :from => :completed, :guard => :approvals_fulfilled?
    transitions :to => :reviewed, :from => :accepted
    transitions :to => :certified, :from => :reviewed, :guard => :approvals_fulfilled?
#    draft_approved_at = DateTime.now unless draft_approved_at?
#    review_approved_at = DateTime.now unless review_approved_at?
  end
  aasm_event :unapprove do
    transitions :to => :started, :from => :completed, :guard => :approvals_unfulfilled?
    transitions :to => :completed, :from => :submitted
    transitions :to => :accepted, :from => :reviewed, :guard => :approvals_unfulfilled?
    transitions :to => :reviewed, :from => :certified
  end
  aasm_event :release do
    transitions :to => :released, :from => :certified
#    released_at = DateTime.now
  end

  alias :requestors :organizations

  def deliver_required_approval_notice
    approvals = approvers.unfulfilled_for_status(status).map { |a| Approval.new( :user => a, :approvable => self ) }
    approvals.each do |approval|
      ApprovalMailer.deliver_request_notice(approval)
    end
  end

  def reviewers
    return Array.new unless basis.organization
    [ basis.organization ]
  end

  # Lists actions available to user on the request
  def may(user)
    return Array.new if user.nil?
    return ACTIONS if user.admin?
    Version::PERSPECTIVES.each do |perspective|
      actions = permissions.allowed_actions( user,
                                             user.roles.in( send(perspective.pluralize) ),
                                             perspective,
                                             status.to_s )
      return actions if actions.first
    end
    Array.new
  end

  # Creates permission checking methods
  # May need to override some to provide additional logic (experiment with super)
  ACTIONS.each do |action|
    define_method("may_#{action}?") do |user|
      # may need to override with custom methods for some actions
      # return false if basis.closed?
      return true if may(user).include?(action)
      false
    end
  end

  def may_create?(user)
    return false if user.nil?
    return true if user.admin? || ( may(user).include?('create') && basis.open? )
    false
  end

  def may_destroy?(user)
    return false if user.nil?
    return true if user.admin? || ( may(user).include?('destroy') && basis.open? )
    false
  end

  def may_update?(user)
    return false if user.nil?
    return true if user.admin? || ( may(user).include?('update') && basis.open? )
    false
  end

  def approvals_fulfilled?
    approvers.fulfill_status?
  end

  def approvals_unfulfilled?
    approvers.empty_for_status?
  end

  def set_approval_checkpoint(datetime=nil)
    self.approval_checkpoint = ( datetime.nil? ? DateTime.now : datetime )
  end

  def reset_approval_checkpoint
    return if approvals.existing.last.nil?
    self.approval_checkpoint = approvals.existing.last.created_at
  end

  def self.aasm_state_names
    Request.aasm_states.map { |s| s.name.to_s }
  end

  def to_s
    "Request of #{organizations.join(", ")} from #{basis}"
  end
end

