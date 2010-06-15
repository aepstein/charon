class RegistrationTerm < ActiveRecord::Base

  named_scope :current, :conditions => { :current => true }

  has_many :registrations, :foreign_key => :external_term_id, :primary_key => :external_id,
    :dependent => :destroy
  has_many :memberships, :through => :registrations

  before_update :will_update_dependencies
  after_update :update_dependencies

  private

  def will_update_dependencies
    @will_update_dependencies = true if current_changed?
  end

  def update_dependencies
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

