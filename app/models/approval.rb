class Approval < ActiveRecord::Base
  belongs_to :approvable, :polymorphic => true
  belongs_to :user

  delegate :may_approve?, :to => :approvable
  delegate :may_unapprove?, :to => :approvable
  delegate :may_unapprove_other?, :to => :approvable
  delegate :approve!, :to => :approvable
  delegate :unapprove!, :to => :approvable

  validates_uniqueness_of :approvable_id, [ :approvable_type, :user_id ]
  validates_presence_of :approvable
  validates_presence_of :user

  after_create :approve!
  after_destroy :unapprove!

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

