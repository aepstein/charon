class RegistrationCriterion < ActiveRecord::Base
  attr_accessible :must_register, :minimal_percentage, :type_of_member

  is_fulfillable

  validates :minimal_percentage, :numericality => { :integer_only => true,
    :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100 }
  validates :type_of_member, :inclusion => { :in => Registration::MEMBER_TYPES }
  validates :must_register, :uniqueness => { :scope =>
    [ :type_of_member, :minimal_percentage ] }

  def organization_ids
    registration_term_ids = RegistrationTerm.current.map(&:id)
    return [] if registration_term_ids.empty?
    connection.select_values(
      "SELECT DISTINCT organizations.id FROM organizations INNER JOIN registrations " +
      "WHERE organizations.id = registrations.organization_id AND " +
      "registrations.registration_term_id IN (#{registration_term_ids.join ','}) AND " +
      (must_register? ? "registrations.registered = #{connection.quote true} AND " : "") +
      "#{minimal_percentage} <= ( number_of_#{type_of_member} * 100.0 / ( " +
      "number_of_undergrads + number_of_grads + number_of_staff + number_of_faculty + number_of_others ) )"
    )
  end

  def to_s(format = nil)
    case format
    when :requirement
      "must have a current registration with #{self}"
    else
      conditions = Array.new
      if minimal_percentage && type_of_member
        conditions << "at least #{minimal_percentage} percent #{type_of_member} members"
      end
      if must_register?
        conditions << "an approved status"
      end
      conditions.join(' and ')
    end
  end
end

