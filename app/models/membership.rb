class Membership < ActiveRecord::Base
  include UserNameLookup
  include OrganizationNameLookup

  default_scope :include => [ :user, :organization ], :order => 'organizations.last_name, organizations.first_name, users.last_name, users.first_name, users.net_id'
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

end

