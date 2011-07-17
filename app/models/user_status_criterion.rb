class UserStatusCriterion < ActiveRecord::Base
  attr_accessible :statuses

  is_fulfillable

  validates_numericality_of :statuses_mask, :only_integer => true, :greater_than => 0
  validates_uniqueness_of :statuses_mask

  def statuses=(statuses)
    self.statuses_mask = (statuses & User::STATUSES).map { |s| 2**User::STATUSES.index(s) }.sum
  end

  def statuses
    User::STATUSES.reject { |s| ((statuses_mask || 0) & 2**User::STATUSES.index(s)).zero? }
  end

  def user_ids
    status_list = statuses.map { |s| connection.quote s }.join ", "
    connection.select_values(
      "SELECT users.id FROM users WHERE users.status " +
      "IN (#{status_list})"
    )
  end

  def to_s; "Status must be #{statuses.join ', '}"; end
end

