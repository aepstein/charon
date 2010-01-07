class RegistrationCriterion < ActiveRecord::Base
  has_many :fulfillments, :as => :fulfillable, :dependent => :delete_all

  validates_numericality_of :minimal_percentage, :integer_only => true,
    :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100
  validates_inclusion_of :type_of_member, :in => Registration::MEMBER_TYPES
  validates_presence_of :must_register

  after_create 'Fulfillment.fulfill self'
  after_update 'Fulfillment.unfulfill self', 'Fulfillment.fulfill self'

  def organization_ids
    connection.select_values(
      "SELECT DISTINCT organizations.id FROM organizations INNER JOIN registrations " +
      "WHERE organizations.id = registrations.organization_id AND " +
      "registrations.registered = #{connection.quote must_register} AND " +
      "#{minimal_percentage} <= ( number_of_#{type_of_member} * 100.0 / ( " +
      "number_of_undergrads + number_of_grads + number_of_staff + number_of_faculty + number_of_others ) )"
    )
  end
end

