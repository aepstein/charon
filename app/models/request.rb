class Request < ActiveRecord::Base

  belongs_to :basis
  has_many :approvals
  has_many :items do
    def children_of(request_item)
      self.select { |item| item.parent_id == request_item.id }
    end
    def root
      self.select { |item| item.parent_id.nil? }
    end
  end
  has_and_belongs_to_many :organizations do
    def allowed?(organization)
      organization.send("#{proxy_owner.basis.structure.kind}_eligible?")
    end
  end

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
  aasm_initial_state :draft
  aasm_state :draft
  aasm_state :approved_draft
  aasm_state :accepted
  aasm_state :review
  aasm_state :approved_review
  aasm_state :released

  aasm_event :accept do
    transitions :to => :accepted, :from => :approved_draft
#    accepted_at = DateTime.now
  end
  aasm_event :review do
    transitions :to => :reviewed, :from => :accepted
  end
  aasm_event :approve do
    transitions :to => :approved_draft, :from => :draft
    transitions :to => :approved_review, :from => :review
#    draft_approved_at = DateTime.now unless draft_approved_at?
#    review_approved_at = DateTime.now unless review_approved_at?
  end
  aasm_event :unapprove do
    transitions :from => :approved_draft, :to => :draft
    transitions :from => :approved_review, :to => :review
    # TODO remove approval timestamps if all approvals for class of review are blank
  end
  aasm_event :release do
    transitions :to => :released, :from => :approved_review
#    released_at = DateTime.now
  end

  def may_create?(user)
    return true unless organizations.select { |o| user.finance_officer_in?(o) }.empty?
    false
  end

  def may_update?(user)
    organizations.each do |o|
      return true if o.memberships.map { |m| m.user }.include?(user)
    end
    false
  end

  def may_see?(user)
    return true unless organizations.select { |o| user.roles.in(o).size > 0 }.empty?
    false
  end

  def may_approve?(user)
    return true unless organizations.select { |o| user.finance_officer_in?(o) }.empty?
    #return true if memberships.map { |m| m.user }.include?(user)
    false
  end

  def to_s
    "Request of #{organizations.join(", ")} from #{basis}"
  end
end

