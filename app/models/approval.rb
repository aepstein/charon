class Approval < ActiveRecord::Base
  default_scope :include => [ :user ], :order => 'users.last_name ASC, users.first_name ASC, users.middle_name ASC'

  belongs_to :approvable, :polymorphic => true
  belongs_to :user

  named_scope :agreements, :conditions => { :approvable_type => 'Agreement' }
  named_scope :requests, :conditions => { :approvable_type => 'Request' }
  named_scope :at_or_after, lambda { |time|
    { :conditions => [ 'approvals.created_at >= ?', time.utc ] }
  }

  validates_datetime :as_of
  validates_uniqueness_of :approvable_id, :scope => [ :approvable_type, :user_id ]
  validates_presence_of :approvable
  validates_presence_of :user
  validate :approvable_must_not_change

  after_create :approve_approvable, :deliver_approval_notice, :fulfill_user
  after_destroy :unapprove_approvable, :deliver_unapproval_notice, :unfulfill_user

  def deliver_approval_notice
    ApprovalMailer.deliver_approval_notice( self )
  end

  def deliver_unapproval_notice
    ApprovalMailer.deliver_unapproval_notice( self )
  end

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
      errors.add_to_base( "#{approvable} has changed since you saw it.  Please review again and confirm approval." )
    end
  end

  def approve_approvable
    begin
      approvable.approve
    rescue AASM::InvalidTransition
      return false
    end
    approvable.save if approvable.changed?
  end

  def unapprove_approvable
    begin
      approvable.unapprove
    rescue AASM::InvalidTransition
      return false
    end
    approvable.save if approvable.changed?
  end

  def fulfill_user
     Fulfillment.fulfill user if approvable_type == "Agreement"
  end

  def unfulfill_user
    Fulfillment.unfulfill user if approvable_type == "Agreement"
  end
end

