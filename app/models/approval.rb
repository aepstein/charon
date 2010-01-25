class Approval < ActiveRecord::Base
  default_scope :include => [ :user ], :order => 'users.last_name ASC, users.first_name ASC, users.middle_name ASC'

  belongs_to :approvable, :polymorphic => true
  belongs_to :user

  delegate :may_approve?, :to => :approvable
  delegate :may_unapprove?, :to => :approvable
  delegate :may_unapprove_other?, :to => :approvable

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

  after_create :approve_approvable, :deliver_approval_notice, 'Fulfillment.fulfill user if approvable_type == "Agreement"'
  after_destroy :unapprove_approvable, :deliver_unapproval_notice, 'Fulfillment.unfulfill user if approvable_type == "Agreement"'

  def approvable_must_not_change
    return unless approvable && as_of
    if approvable.updated_at.to_s.to_datetime > as_of
      errors.add_to_base( "#{approvable} has changed since you saw it.  Please review again and confirm approval." )
    end
  end

  def deliver_approval_notice
    ApprovalMailer.deliver_approval_notice(self)
  end

  def deliver_unapproval_notice
    ApprovalMailer.deliver_unapproval_notice(self)
  end

  def as_of=(datetime)
    @as_of=datetime.to_s
  end

  def as_of
    return nil unless @as_of
    @as_of.to_datetime
  end

  def approve_approvable
    approvable.approve
    approvable.save if approvable.changed?
  end

  def unapprove_approvable
    approvable.unapprove
    approvable.save if approvable.changed?
  end

  def may_see?(user)
    return false unless user && self.user
    self.user == user || user.admin?
  end

  def may_create?(user)
    may_approve? user
  end

  def may_destroy?(user)
    return false unless user
    return true if self.user == user && may_unapprove?( user )
    may_unapprove_other? user
  end

  def to_s
    "Approval of #{user} for #{request}"
  end
end

