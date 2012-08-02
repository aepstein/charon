class Membership < ActiveRecord::Base
  include UserNameLookup
  include OrganizationNameLookup

  attr_accessible :role_id, :active, :user_name, :organization_name
  attr_readonly :registration_id, :member_source_id

  scope :ordered, joins { [ organization, user ] }.
    order { [ organizations.last_name, organizations.first_name,
    users.last_name, users.first_name, users.net_id ] }
  scope :active, where( active: true )
  scope :inactive, where { active.not_eq( true ) }
  scope :requestor, lambda {
    active.where { role_id.in( Role.requestor.select { id } ) }
  }
  scope :reviewer, lambda {
    active.where { role_id.in( Role.reviewer.select { id } ) }
  }
  scope :manager, lambda {
    active.where { role_id.in( Role.manager.select { id } ) }
  }
  scope :fulfill_single_role, lambda { |framework|
    return scoped unless framework.requirements.select(&:role_id).any?
    where { |m|
      m.role_id.not_in( framework.requirements.single_role.scoped.select { role_id } ) |
      framework.requirement_roles.map { |role|
        m.role_id.eq( role.id ) &
        framework.requirements.single_role.select { |r| r.role_id == role.id }.
        map { |requirement| requirement.fulfillment_criterion m }.inject(:&)
      }.inject(:|)
    }
  }
  scope :fulfill_all_role, lambda { |framework|
    return scoped unless framework.requirements.reject(&:role_id).any?
    where { |m|
        framework.requirements.all_roles.
        map { |requirement| requirement.fulfillment_criterion m }.inject(:&)
    }
  }
  # Find all memberships which fulfill a framework
  # * not subject to role-specified or meets all role-specified
  # * meets all organizational
  scope :fulfill, lambda { |framework|
    fulfill_single_role( framework ).fulfill_all_role( framework )
  }

  belongs_to :user, inverse_of: :memberships
  belongs_to :role, inverse_of: :memberships
  belongs_to :registration, inverse_of: :memberships
  belongs_to :organization, inverse_of: :memberships
  belongs_to :member_source, inverse_of: :memberships
  has_and_belongs_to_many :frameworks

  before_validation :set_organization_from_registration, :set_from_member_source
  after_save :update_frameworks

  validates :user, presence: true
  validates :role, presence: true
  validate :must_have_registration_or_organization

  def update_frameworks
    return true if Framework.skip_update_frameworks
    self.frameworks.clear unless active?
    self.frameworks = Framework.fulfilled_by( self )
  end

  def set_organization_from_registration
    if registration
      self.active = registration.current?
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

