class Organization < ActiveRecord::Base
  has_many :users, :through => :memberships, :conditions => ['memberships.active = ?', true]
  has_many :registrations do
    def current
      self.active.first
    end
  end
  has_many :memberships
  has_many :bases
  has_and_belongs_to_many :requests do
    def creatable
      Basis.open.no_draft_request_for( proxy_owner
      ).select { |b| proxy_owner.eligible_for?(b.framework) }.map { |b| b.requests.build_for( proxy_owner ) }
    end
  end
  has_many :fulfillments, :as => :fulfiller, :dependent => :delete_all

  before_validation :format_name

  default_scope :order => 'organizations.last_name ASC, organizations.first_name ASC'

  validates_uniqueness_of :last_name, :scope => :first_name

  def unfulfilled_permissions
    Permission.requirements_unfulfilled.requirements_with_fulfillments.memberships_organization_id_eq(id)
  end

  def unfulfilled_requirements
    unfulfilled_permissions.all(:include => [:role, :framework, :requirements]).inject({}) do |memo, permission|
      permission.requirements.each do |requirement|
        memo[requirement.fulfillable] = [] unless memo.include? requirement.fulfillable
        memo[requirement.fulfillable] << permission unless memo[requirement.fulfillable].include? permission
      end
      memo
    end
  end

  def registration_criterions
    return [] unless registrations.current
    registrations.current.registration_criterions
  end

  def registration_criterion_ids
    registration_criterions.map { |criterion| criterion.id }
  end

  def name
    ( first_name.nil? || first_name.empty? ) ? last_name : "#{first_name} #{last_name}"
  end

  def format_name
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

