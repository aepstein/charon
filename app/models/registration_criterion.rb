class RegistrationCriterion < ActiveRecord::Base
  after_create do |criterion|
    # Fulfill all registered organizations
  end

  after_update do |criterion|
  end
end

