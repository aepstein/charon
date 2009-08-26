class Membership < ActiveRecord::Base
  named_scope :active, :conditions => { :active => true }
  named_scope :in, lambda { |organization_ids|
    { :conditions => { :organization_id => organization_ids } }
  }

  belongs_to :user
  belongs_to :role
  belongs_to :registration
  belongs_to :organization

  before_validation :set_organization_from_registration

  validates_presence_of :user
  validates_presence_of :role
  validate :must_have_registration_or_organization

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

  def may_see?( user )
    user.admin? || self.user == user
  end

  def may_update?( user )
    user.admin?
  end

  def may_create?( user )
    user.admin?
  end

  def may_destroy?( user )
    user.admin?
  end
end

