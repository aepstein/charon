class Approval < ActiveRecord::Base
  belongs_to :approvable, :polymorphic => true
  belongs_to :user

  delegate :may_approve?, :to => :approvable
  delegate :may_unapprove?, :to => :approvable
  delegate :may_unapprove_other?, :to => :approvable
  delegate :approvals_fulfilled?, :to => :approvable
  delegate :approvals_unfulfilled?, :to => :approvable

  named_scope :agreements, :conditions => { :approvable_type => 'Agreement' }
  named_scope :requests, :conditions => { :approvable_type => 'Request' }
  named_scope :at_or_after, lambda { |time|
    { :conditions => [ 'approvals.created_at >= ?', time.utc ] }
  }

  validates_uniqueness_of :approvable_id, :scope => [ :approvable_type, :user_id ]
  validates_presence_of :approvable
  validates_presence_of :user

  after_create :approve_approvable
  after_destroy :unapprove_approvable

  def approve_approvable
    approvable.approve! if approvals_fulfilled?
  end

  # TODO must be more robust
  def unapprove_approvable
    approvable.unapprove! if approvals_unfulfilled?
  end

  def may_create?(user)
    may_approve? user
  end

  def may_destroy?(user)
    return true if self.user == user && may_unapprove?( user )
    may_unapprove_other? user
  end

  def to_s
    "Approval of #{user} for #{request}"
  end
end

