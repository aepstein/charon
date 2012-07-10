class UserStatusCriterion < ActiveRecord::Base
  attr_accessible :statuses

  is_fulfillable 'User'

  scope :with_status, lambda { |status|
    unless status.blank? || User::STATUSES.index(status).blank?
      where "statuses_mask & #{2**User::STATUSES.index(status)} > 0"
    else
      where { id.eq( nil ) }
    end
  }
  scope :fulfilled_by, lambda { |user|
    unless user.class.to_s == 'User'
      raise ArgumentError, "received #{user.class} instead of User"
    end
    with_status( user.status )
  }

  validates :statuses_mask, uniqueness: true,
    numericality: { only_integer: true, greater_than: 0 }

  def statuses=(statuses)
    self.statuses_mask = (statuses & User::STATUSES).map { |s| 2**User::STATUSES.index(s) }.sum
  end

  def statuses
    User::STATUSES.reject { |s| ((statuses_mask || 0) & 2**User::STATUSES.index(s)).zero? }
  end

  def to_s(format = nil)
    case format
    when :requirement
      "must be #{statuses.join ' or '}"
    else
      "Status must be #{statuses.join ', '}"
    end
  end
end

