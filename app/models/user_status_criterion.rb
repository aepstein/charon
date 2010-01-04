class UserStatusCriterion < ActiveRecord::Base
  validates_numericality_of :statuses_mask
  validates_uniqueness_of :statuses_mask

  def statuses=(statuses)
    self.statuses_mask = (statuses & User::STATUSES).map { |s| 2**User::STATUSES.index(s) }.sum
  end

  def statuses
    User::STATUSES.reject { |s| ((statuses_mask || 0) & 2**User::STATUSES.index(s)).zero? }
  end

  after_create do |criterion|
    # TODO
    # Fulfill all users meeting criteria
  end

  after_update do |criterion|
    # TODO
    # Unfulfill all users not meeting criteria
    # Fulfill users meeting criteria who are not already fulfilled
  end
end

