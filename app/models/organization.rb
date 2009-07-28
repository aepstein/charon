class Organization < ActiveRecord::Base
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

  before_validation :format_name

  validates_uniqueness_of :last_name, :scope => :first_name

  def name
    ( first_name.nil? || first_name.empty? ) ? last_name : "#{first_name} #{last_name}"
  end

  def self.find_or_create_by_registration(registration)
    return registration.organization unless registration.organization.nil?
    organization = Organization.create(registration.attributes_for_organization)
    organization.registrations << registration
    organization
  end

  def format_name
    self.first_name = "" unless first_name.class == String
    while match = last_name.match(/\A(Cornell|The|An|A)\s+(.*)\Z/) do
      self.first_name = "#{first_name} #{match[1]}".strip
      self.last_name = match[2]
    end
  end

  def eligible_for?(framework)
    return true unless framework.must_register?
    return false unless registrations.current
    registations.current.eligible_for? framework
  end

  def may_see?(user)
    true
  end

  # TODO is this sufficient?
  def may_edit?(user)
    user.admin?
  end

  def to_s
    name
  end
end

