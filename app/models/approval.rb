class Approval < ActiveRecord::Base
  belongs_to :approvable, :polymorphic => true
  belongs_to :user, :inverse_of => :approvals

  default_scope includes( :user ).
    order( 'users.last_name ASC, users.first_name ASC, users.middle_name ASC' )

  scope :agreements, where( :approvable_type => 'Agreement' )
  scope :requests, where( :approvable_type => 'Request' )
  scope :at_or_after, lambda { |time| where( :created_at.gte => time ) }

  validates_datetime :as_of
  validates_uniqueness_of :approvable_id, :scope => [ :approvable_type, :user_id ]
  validates_presence_of :approvable
  validates_presence_of :user
  validate :approvable_must_not_change

  after_create :approve_approvable, :deliver_approval_notice, :fulfill_user
  after_destroy :unapprove_approvable, :deliver_unapproval_notice, :unfulfill_user

  def as_of=(datetime)
    @as_of=datetime.to_s
  end

  def as_of
    return nil unless @as_of
    @as_of.to_datetime
  end

  def to_s; "Approval of #{user} for #{request}"; end

  protected

  def approvable_must_not_change
    return unless approvable && as_of
    if approvable.updated_at.to_s.to_datetime > as_of
      errors.add :base,
        "#{approvable} has changed since you saw it.  Please review again and confirm approval."
    end
  end

  def deliver_approval_notice
    ApprovalMailer.approval_notice( self ).deliver
  end

  def deliver_unapproval_notice
    ApprovalMailer.unapproval_notice( self ).deliver
  end

  def approve_approvable
    begin
      approvable.approve
    rescue StateMachine::InvalidTransition
      return false
    end
  end

  def unapprove_approvable
    begin
      approvable.unapprove
    rescue StateMachine::InvalidTransition
      return false
    end
  end

  def fulfill_user
    user.approvals.reset
    user.fulfill if approvable_type == "Agreement"
  end

  def unfulfill_user
    user.approvals.reset
    user.unfulfill if approvable_type == "Agreement"
  end
end

