class RegisteredMembershipCondition < ActiveRecord::Base
  has_many :fulfillments, :as => :condition, :dependent => :destroy
  has_many :fulfillers, :through => :fulfillments do
    def synchronize(registration)
      if registration.active? && ( registration.percent_members_of_type( membership_type ) >= membership_percentage )
        fulfillers << registration unless fulfillers.include?(registration)
      else
        fulfillers.delete(registration) if fulfillers.include?(registration)
      end
    end
  end

  after_save :synchronize_fulfillments

  def synchronize_fulfillments
    fulfillers.each do |registration|
      fulfillers.delete(registration) if registration.percent_members_of_type(membership_type) < membership_percentage
    end
    Registration.active.min_percent_members_of_type( membership_percentage, membership_type ).each do |registration|
      fulfillers << registration unless fulfillers.include?(registration)
    end
  end

  def to_s
    "#{membership_type.capitalize} must be at least #{membership_percentage}% of members"
  end
end

