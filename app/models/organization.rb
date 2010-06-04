class Organization < ActiveRecord::Base
  has_many :users, :through => :memberships, :conditions => ['memberships.active = ?', true]
  has_many :registrations do
    def current
      self.active.first
    end
  end
  has_many :memberships
  has_many :roles, :through => :memberships
  has_many :bases do
    def requestable
      Basis.open.no_draft_request_for( proxy_owner )
    end
  end
  has_many :requests do
    def creatable
      proxy_owner.bases.requestable.map { |basis| build( :basis => basis ) }
    end
  end
  has_many :fulfillments, :as => :fulfiller, :dependent => :delete_all

  before_validation :format_name

  default_scope :order => 'organizations.last_name ASC, organizations.first_name ASC'
  scope_procedure :name_like, lambda { |name| first_name_like_or_last_name_like( name ) }

  validates_presence_of :last_name
  validates_uniqueness_of :last_name, :scope => :first_name

  def permissions
    Permission.role_id_equals_any(role_ids)
  end

  def unfulfilled_permissions
    Permission.requirements_unfulfilled.requirements_with_fulfillments.requirements_fulfillable_type_equals_any(
    Fulfillment::FULFILLABLE_TYPES['Organization']).memberships_organization_id_eq(id)
  end

  def unfulfilled_requirements
    requirements = Requirement.unfulfilled.with_fulfillments.fulfillable_type_equals_any(
    Fulfillment::FULFILLABLE_TYPES['Organization']).permission_memberships_organization_id_eq(id)
    fulfillables = requirements.all.inject([]) do |memo, requirement|
      memo << [ requirement.fulfillable_type, requirement.fulfillable_id ]
      memo
    end
    fulfillables.uniq.map { |f| f.first.constantize.find f.last }
  end

  def registration_criterions
    return [] unless registrations.current
    registrations.current.registration_criterions
  end

  def registration_criterion_ids
    registration_criterions.map { |criterion| criterion.id }
  end

  def registered?
    return false unless registrations.current
    registrations.current.registered?
  end

  def name
    ( first_name.nil? || first_name.empty? ) ? last_name : "#{first_name} #{last_name}"
  end

  def format_name
    return unless last_name
    self.first_name = "" unless first_name.class == String
    while match = last_name.match(/\A(Cornell|The|An|A)\s+(.*)\Z/) do
      self.first_name = "#{first_name} #{match[1]}".strip
      self.last_name = match[2]
    end
  end

  def may_see?(user)
    true
  end

  # TODO is this sufficient?
  def may_update?(user)
    user.admin?
  end

  def may_create?(user)
    user.admin? && new_record?
  end

  def may_destroy?(user)
    user.admin?
  end

  def to_s
    name
  end
end

