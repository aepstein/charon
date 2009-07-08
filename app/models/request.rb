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
  has_and_belongs_to_many :organizations

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
    accepted_at = DateTime.now
  end
  aasm_event :review do
    transitions :to => :reviewed, :from => :accepted
  end
  aasm_event :approve do
    transitions :to => :approved_draft, :from => :draft
    transitions :to => :approved_review, :from => :review
    draft_approved_at = DateTime.now unless draft_approved_at?
    review_approved_at = DateTime.now unless review_approved_at?
  end
  aasm_event :unapprove do
    transitions :from => :approved_draft, :to => :draft
    transitions :from => :approved_review, :to => :review
    # TODO remove approval timestamps if all approvals for class of review are blank
  end
  aasm_event :release do
    transitions :to => :released, :from => :approved_review
    released_at = DateTime.now
  end

  def may?(user, action)
    case action
    when :create, :update
      return false if basis.closed_at < DateTime.now
      return false if organizations.select { |o| o.send("#{basis.kind}_eligible?") }.empty?
      if draft?
        organizations.each { |o| return true if user.roles.officer_in?(o) }
      end
      if review?
        # TODO basis should provide eligible reviewers through a controlling organization
      end
    when :approve
      organizations.select { |o| return false unless o.send("#{basis.kind}_eligible?") }
      if draft? || approved_draft?
        organizations.each { |o| return true if user.roles.finance_officer_in?(o) }
      end
      if review? || approved_review?
        # TODO basis should provide eligible approvers through a controlling organization
      end
      return true
    end
    false
  end

  def to_s
    "Request of #{organizations.join(", ")} from #{basis}"
  end
end

