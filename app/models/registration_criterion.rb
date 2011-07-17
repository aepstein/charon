class RegistrationCriterion < ActiveRecord::Base
  attr_accessible :must_register, :minimal_percentage, :type_of_member

  is_fulfillable

  validates_numericality_of :minimal_percentage, :integer_only => true,
    :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100
  validates_inclusion_of :type_of_member, :in => Registration::MEMBER_TYPES
  validates_uniqueness_of :must_register, :scope => [ :type_of_member, :minimal_percentage ]

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

  def to_s
    out = "No less than #{minimal_percentage} percent of members provided in the " +
      "current registration must be #{type_of_member}"
    out += " and the registration must be approved" if must_register?
    out
  end
end

