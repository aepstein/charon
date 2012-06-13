class Membership < ActiveRecord::Base
  include UserNameLookup
  include OrganizationNameLookup

  attr_accessible :role_id, :active, :user_name, :organization_name
  attr_readonly :registration_id, :member_source_id

  attr_accessor :skip_update_frameworks

  scope :ordered, includes( :user, :organization ).
    order( 'organizations.last_name, organizations.first_name, users.last_name, ' +
      'users.first_name, users.net_id' )
  scope :active, where( active: true )
  scope :inactive, where { active.not_eq( true ) }
  # Find all memberships which fulfill a framework
  # * not subject to role-specified or meets all role-specified
  # * meets all organizational
  scope :fulfill, lambda { |framework|
    if framework.requirements.single_role.any?
      where { |m|
        m.role_id.not_in( framework.requirements.single_role.scoped.select { role_id } ) |
        framework.requirement_roles.map { |role|
          m.role_id.eq( role.id ) &
          framework.requirements.single_role.select { |r| r.role_id == role.id }.
          map { |requirement| requirement.fulfillment_criterion m }.inject(:&)
        }.inject(:|)
      }.
      where { |m|
        framework.requirements.all_roles.
        map { |requirement| requirement.fulfillment_criterion m }.inject(:&)
      }
    else
      scoped
    end
  }

  belongs_to :user, inverse_of: :memberships
  belongs_to :role, inverse_of: :memberships
  belongs_to :registration, inverse_of: :memberships
  belongs_to :organization, inverse_of: :memberships
  belongs_to :member_source, inverse_of: :memberships
  has_and_belongs_to_many :frameworks do
    def update!
      proxy_association.owner.send :frameworks=,
        Framework.fulfilled_by( proxy_association.owner )
    end
  end

  before_validation :set_organization_from_registration, :set_from_member_source
  after_save 'frameworks.update! unless skip_update_frameworks'

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

