class Membership < ActiveRecord::Base
  named_scope :active, :conditions => { :active => true }
  named_scope :in, lambda { |organization_ids|
    { :conditions => { :organization_id => organization_ids } }
  }
  scope_procedure :for_fulfiller, lambda { |fulfiller|
    send fulfiller.fulfiller_type.underscore + "_id_eq", fulfiller.id
  }
  scope_procedure :unfulfilled_for, lambda { |fulfiller|
    permissions_unsatisfied.for_fulfiller fulfiller
  }

  belongs_to :user
  belongs_to :role
  belongs_to :registration
  belongs_to :organization

  before_validation :set_organization_from_registration

  validates_presence_of :user
  validates_presence_of :role
  validate :must_have_registration_or_organization

  def fulfiller_name( fulfillable )
    return unless user_id && organization_id
    send(fulfillable.fulfiller_type.underscore).name
  end

  def set_organization_from_registration
    if registration && ( organization != registration.organization ) then
      self.organization = registration.organization
    end
    active = registration.active? if registration
  end

  def must_have_registration_or_organization
    errors.add_to_base( 'Must have a registration or organization.'
    ) unless registration || organization
  end

end

