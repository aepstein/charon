class RegistrationCriterion < ActiveRecord::Base
  attr_accessible :must_register, :minimal_percentage, :type_of_member

  is_fulfillable 'Organization'

  scope :minimal_percentage_fulfilled_by, lambda { |registration|
    where { |r|
      Registration::MEMBER_TYPES.map { |type|
        r.type_of_member.eq( type ) & ( r.minimal_percentage.lte(
          registration.percent_members_of_type( type ) ) )
      }.inject(:|) | r.type_of_member.eq( nil ) | r.minimal_percentage.eq( nil )
    }
  }
  scope :must_register_fulfilled_by, lambda { |registration|
    if registration.registered?
      scoped
    else
      where { must_register.not_eq( true ) }
    end
  }
  scope :fulfilled_by_registration, lambda { |registration|
    minimal_percentage_fulfilled_by(registration).must_register_fulfilled_by(registration)
  }
  scope :fulfilled_by, lambda { |organization|
    if organization.current_registration
      fulfilled_by_registration organization.current_registration
    else
      where id: nil
    end
  }

  validates :minimal_percentage, numericality: { integer_only: true,
    greater_than_or_equal_to: 0, less_than_or_equal_to: 100,
    allow_blank: true }
  validates :type_of_member, inclusion: { in: Registration::MEMBER_TYPES,
    allow_blank: true }
  validates :must_register,
    uniqueness: { scope: [ :type_of_member, :minimal_percentage ] }


  def minimal_percentage_of_type?
    minimal_percentage? && type_of_member?
  end

#  def organization_ids
#    organizations.map(&:id)
#  end

#  # Returns organizations with fulfilling registrations
#  def organizations
#    Organization.where { id.in(
#      my { registrations.except(:order).select { organization_id } }
#    ) }
#  end

#  # Returns registrations fulfilling this criterion
#  # * only active registrations
#  # * match member composition component, if present
#  # * match registration status component, if present
#  def registrations
#    scope = Registration.scoped.active
#    if minimal_percentage && type_of_member
#      scope = scope.min_percent_members_of_type minimal_percentage, type_of_member
#    end
#    if must_register
#      scope = scope.registered
#    end
#    scope
#  end

  def to_s(format = nil)
    case format
    when :requirement
      "must have a current registration with #{to_s}"
    else
      conditions = Array.new
      if minimal_percentage && type_of_member
        conditions << "at least #{minimal_percentage} percent #{type_of_member}"
      end
      if must_register?
        conditions << "an approved status"
      end
      conditions.join(' and ')
    end
  end
end

