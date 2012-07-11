class RegistrationTerm < ActiveRecord::Base
  attr_accessible :short_description, :description, :current, :starts_at, :ends_at
  attr_readonly :external_id

  scope :current, where( current: true )

  validates :external_id, numericality: { integer_only: true, greater_than: 0 },
    presence: true

  has_many :registrations, dependent: :nullify, inverse_of: :registration_term do
    # Update registrations:
    # * dissociate registrations that do not have a non-matching external term id
    # * associate registrations that have a matching external term id
    # * reset association to reflect any changes made
    def adopt!
      Registration.update_all(
        "registration_term_id = NULL",
        "registration_term_id = #{proxy_association.owner.id} AND external_term_id IS NOT NULL AND " +
        "external_term_id <> #{proxy_association.owner.external_id}"
      )
      Registration.update_all(
        "registration_term_id = #{proxy_association.owner.id}",
        "external_term_id = #{proxy_association.owner.external_id}"
      )
      proxy_association.reset
    end
  end
  has_many :memberships, through: :registrations do
    # Sets memberships' activation status to match registration setting
    def activate!
      ids = proxy_association.owner.registration_ids
      return if ids.empty?
      scoped.update_all "active = #{connection.quote proxy_association.owner.current?}",
        "registration_id IN (#{ids.join ','})"
      proxy_association.reset
    end
  end

  after_save { |term| term.registrations.adopt! }
  after_update :update_dependencies

  def to_s; description; end

  # Because of excessive TimeWithZone precision, we need to do a fuzzy comparison
  # on time attributes
  def changed_significantly?
    return false unless changed?
    return true if ( changes.keys - %w( starts_at ends_at ) ).any?
    %w( starts_at ends_at ).each do |attribute|
      if send "#{attribute}_changed?"
        return true if changes[attribute].first.to_i != changes[attribute].last.to_i
      end
    end
    false
  end

  private

  # Update dependent entities if registration's 'current' status is changed
  # * Update activation status for memberships
  # * Update fulfillments for associated memberships when appropriate
  def update_dependencies
    return true unless current_changed?
    memberships.activate!
    Framework.where { id.in( Requirement.joins { fulfillable(RegistrationCriterion) }.
      where { registration_criterions.must_register.eq( true ) }.
      select { framework_id } ) }.each do |framework|
      framework.update_memberships
    end
    true
  end

end

