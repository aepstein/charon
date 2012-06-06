class Membership < ActiveRecord::Base
  include UserNameLookup
  include OrganizationNameLookup

  attr_accessible :role_id, :active, :user_name, :organization_name
  attr_readonly :registration_id, :member_source_id

  scope :ordered, includes( :user, :organization ).
    order( 'organizations.last_name, organizations.first_name, users.last_name, ' +
      'users.first_name, users.net_id' )
  scope :active, where( :active => true )
  scope :inactive, where( 'memberships.active IS NULL or memberships.active = ?', false )

  belongs_to :user, inverse_of: :memberships
  belongs_to :role, inverse_of: :memberships
  belongs_to :registration, inverse_of: :memberships
  belongs_to :organization, inverse_of: :memberships
  belongs_to :member_source, inverse_of: :memberships

  before_validation :set_organization_from_registration, :set_from_member_source

  validates :user, presence: true
  validates :role, presence: true
  validate :must_have_registration_or_organization

  def set_organization_from_registration
    if registration
      self.active = registration.active?
      self.organization = registration.organization if registration.organization
    end
    true
  end

  def set_from_member_source
    if member_source
      self.role = member_source.role
      self.organization = member_source.organization
    end
  end

  def must_have_registration_or_organization
    errors.add( :base, 'Must have a registration or organization.' ) unless (registration || organization)
  end

end

