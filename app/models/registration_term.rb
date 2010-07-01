class RegistrationTerm < ActiveRecord::Base

  named_scope :current, :conditions => { :current => true }

  has_many :registrations,:dependent => :nullify
  has_many :memberships, :through => :registrations

  before_update :will_update_dependencies
  after_save :adopt_registrations
  after_update :update_dependencies

  private

  def will_update_dependencies
    @will_update_dependencies = true if current_changed?
  end

  def adopt_registrations
    Registration.update_all(
      "registration_term_id = NULL",
      "registration_term_id = #{id} AND external_term_id IS NOT NULL AND " +
      "external_term_id <> #{external_id}"
    )
    Registration.update_all(
      "registration_term_id = #{id}",
      "external_term_id = #{external_id}"
    )
    registrations.reload
  end

  def update_dependencies
    return unless @will_update_dependencies
    RegistrationCriterion.all.each do |criterion|
      Fulfillment.fulfill criterion
      Fulfillment.unfulfill criterion
    end
    registration_ids = registrations.map(&:id)
    return if registration_ids.empty?
    Membership.update_all( "active = #{connection.quote current?}",
      "registration_id IN (#{registration_ids.join ','})" )
  end

end

