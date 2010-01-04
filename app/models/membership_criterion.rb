class MembershipCriterion < ActiveRecord::Base
  has_many :fulfillments, :as => :fulfilled, :dependent => :delete_all

  validates_numericality_of :membership_percentage, :integer_only => true,
    :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100
  validates_presence_of :type_of_member, :in => User::STATUSES

  after_create do |criterion|
    # TODO
    # Fulfill all organizations whose active registration has required membership
  end

  after_destroy do |criterion|
    # TODO
    # Unfulfill all organizations no longer meeting requirement
    # Fulfill all organizations meeting requirement that are not yet fulfilled
  end
end

