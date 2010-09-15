class Membership < ActiveRecord::Base
  include UserNameLookup
  include OrganizationNameLookup

  default_scope :include => [ :user, :organization ],
    :order => 'organizations.last_name, organizations.first_name, users.last_name, users.first_name, users.net_id'
  named_scope :active, :conditions => { :active => true }
  named_scope :inactive, :conditions => [ 'memberships.active IS NULL or memberships.active = ?', false ]

  belongs_to :user
  belongs_to :role
  belongs_to :registration
  belongs_to :organization
  belongs_to :member_source

  before_validation :set_organization_from_registration

  validates_presence_of :user
  validates_presence_of :role
  validate :must_have_registration_or_organization

  def set_organization_from_registration
    unless registration.blank?
      self.active = registration.active?
      self.organization = registration.organization unless registration.organization.blank?
    end
  end

  def must_have_registration_or_organization
    errors.add_to_base( 'Must have a registration or organization.' ) unless (registration || organization)
  end

end

