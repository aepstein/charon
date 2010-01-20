class RegistrationCriterion < ActiveRecord::Base
  include GlobalModelAuthorization, Fulfillable

  has_many :fulfillments, :as => :fulfillable, :dependent => :delete_all

  validates_numericality_of :minimal_percentage, :integer_only => true,
    :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100
  validates_inclusion_of :type_of_member, :in => Registration::MEMBER_TYPES
  validates_uniqueness_of :must_register, :scope => [ :type_of_member, :minimal_percentage ]

  after_save 'Fulfillment.fulfill self'
  after_update 'Fulfillment.unfulfill self'

  def organization_ids
    # TODO a registration will be considered current/active IFF external_id is set -- correct?
    connection.select_values(
      "SELECT DISTINCT organizations.id FROM organizations INNER JOIN registrations " +
      "WHERE organizations.id = registrations.organization_id AND " +
      "registrations.external_id IS NOT NULL AND " +
      (must_register? ? "registrations.registered = #{connection.quote true} AND " : "") +
      "#{minimal_percentage} <= ( number_of_#{type_of_member} * 100.0 / ( " +
      "number_of_undergrads + number_of_grads + number_of_staff + number_of_faculty + number_of_others ) )"
    )
  end

  def to_s
    out = "No less than #{minimal_percentage} percent of members provided in the " +
      "organization's current registration must be #{type_of_member}"
    out += " and the organization must be registered" if must_register?
    out
  end
end

