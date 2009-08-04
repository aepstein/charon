class Request < ActiveRecord::Base
  ACTIONS = %w( create update destroy see approve unapprove accept revise review release )
  belongs_to :basis
  has_many :approvals, :dependent => :destroy, :as => :approvable
  has_many :items, :dependent => :destroy, :include => [ :node, :parent, :versions ] do
    def children_of(parent_item)
      self.select { |item| item.parent_id == parent_item.id }
    end
    def root
      self.select { |item| item.parent_id.nil? }
    end
  end
  has_and_belongs_to_many :organizations do
    def allowed?(organization)
      organization.eligible_for?(proxy_owner.framework)
    end
  end

  delegate :structure, :to => :basis
  delegate :framework, :to => :basis
  delegate :nodes, :to => :structure
  delegate :permissions, :to => :framework

  validate :must_have_open_basis, :must_have_eligible_organizations

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
  aasm_state :completed
  aasm_state :submitted
  aasm_state :accepted
  aasm_state :reviewed
  aasm_state :certified
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
    transitions :to => :reviewed, :from => :accepted
#    draft_approved_at = DateTime.now unless draft_approved_at?
#    review_approved_at = DateTime.now unless review_approved_at?
  end
  aasm_event :unapprove do
    transitions :to => :started, :from => :completed
    transitions :to => :accepted, :from => :reviewed
  end
  aasm_event :release do
    transitions :to => :released, :from => :certified
#    released_at = DateTime.now
  end

  alias :requestors :organizations

  def reviewers
    return Array.new unless basis.organization
    [ basis.organization ]
  end

  # Lists actions available to user on the request
  def may(user)
    return Array.new if user.nil?
    return ACTIONS if user.admin?
    Version::PERSPECTIVES.each do |perspective|
      actions = permissions.allowed_actions( user.roles.in( send(perspective.pluralize) ),
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

  def self.aasm_state_names
    Request.aasm_states.map { |s| s.name.to_s }
  end

  def to_s
    "Request of #{organizations.join(", ")} from #{basis}"
  end
end

