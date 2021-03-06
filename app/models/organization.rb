class Organization < ActiveRecord::Base
  SEARCHABLE = [ :name_contains ]
  attr_accessible :organization_profile_attributes
  attr_accessible :first_name, :last_name, :fund_tiers_attributes,
    :organization_profile_attributes, :member_sources_attributes,
    :university_accounts_attributes, as: :admin

  notifiable_events :registration_required
  is_fulfiller 'RegistrationCriterion'

  has_one :organization_profile, inverse_of: :organization,
    dependent: :destroy
  has_many :activity_reports, dependent: :destroy, inverse_of: :organization
  has_many :activity_accounts, through: :fund_grants
  has_many :fund_grants, dependent: :destroy, inverse_of: :organization
  has_many :fund_requests, through: :fund_grants
  has_many :fund_tiers, inverse_of: :organization, dependent: :destroy
  has_many :fund_sources, inverse_of: :organization do
    #  What fund sources is this organization eligible to start a grant for?
    # * must have an open deadline (submit_at is in the future)
    # * must fulfill criteria for user
    # * must not have a prior grant created
    def allowed_for( user )
      startable.fulfilled_for_memberships(
          proxy_association.owner.memberships.requestor.where {
            user_id.eq( user.id )
          }
      )
    end

    def unfulfilled_for( user )
      startable.unfulfilled_for_memberships(
          proxy_association.owner.memberships.requestor.where {
            user_id.eq( user.id )
          }
      )
    end

    def released
      FundSource.where { |s| s.id.in( proxy_association.owner.fund_grants.
        where { id.in( FundRequest.unscoped.released.select { fund_grant_id } ) }.
        select { fund_source_id } ) }
    end

    # Startable
    def startable; no_fund_grant.open_deadline_for_first; end

    # For what sources has no grant been created for this organization?
    def no_fund_grant
      FundSource.no_fund_grant_for( proxy_association.owner )
    end
  end
  has_many :inventory_items, dependent: :destroy, inverse_of: :organization
  # These are memberships that must be destroyed if the organization is destroyed
  has_many :dependent_memberships, dependent: :destroy, class_name: 'Membership',
    conditions: { registration_id: nil }
  # These are memberships that should only be nullified if the organization is destroyed
  has_many :independent_memberships, dependent: :nullify, class_name: 'Membership',
    conditions: 'memberships.registration_id IS NOT NULL'
  # Pull only active memberships
  has_many :active_memberships, conditions: { active: true }, class_name: 'Membership'
  # This is the relationship through which memberships should be accessed and manipulated
  has_many :memberships, inverse_of: :organization
  has_many :member_sources, inverse_of: :organization
  has_many :registrations, dependent: :nullify, inverse_of: :organization
  has_one :current_registration, class_name: 'Registration',
    conditions: [ "registrations.registration_term_id IN (SELECT " +
      "id FROM registration_terms WHERE current = ?)", true ]
  has_many :roles, through: :memberships do
    def user_id_equals( id )
      scoped.where( 'memberships.user_id = ?', id )
    end
    def ids_for_user( user )
      user_id_equals( user.id ).all.map(&:id)
    end
  end
  has_many :university_accounts, dependent: :destroy, inverse_of: :organization
  has_many :users, through: :memberships, conditions: { memberships: { active: true } }
  belongs_to :last_current_registration, class_name: 'Registration'
  has_many :last_current_users, through: :last_current_registration,
    source: :users
  has_many :fund_tier_assignments, inverse_of: :organization, dependent: :destroy

  accepts_nested_attributes_for :fund_tiers, allow_destroy: true,
    reject_if: :all_blank
  accepts_nested_attributes_for :organization_profile, update_only: true
  accepts_nested_attributes_for :member_sources, allow_destroy: true,
    reject_if: :all_blank
  accepts_nested_attributes_for :university_accounts, allow_destroy: true

  before_validation :format_name

  scope :ordered, lambda { order { [ last_name, first_name ] } }
  scope :name_contains, lambda { |name|
    sql = %w( first_name last_name ).inject([]) do |memo, field|
      memo << "organizations.#{field} LIKE :name"
    end
    where( sql.join(' OR '), :name => "%#{name}%" )
  }
  scope :fulfill_registration_criterion, lambda { |criterion|
    joins { current_registration.outer }.
    merge( Registration.unscoped.fulfill_registration_criterion criterion )
  }

  validates :last_name, presence: true, uniqueness: { scope: [ :first_name ] }

  def registered?
    current_registration && current_registration.registered?
  end

  # Checks whether requestor recipients are present as active members
  # If at least one active membership is present in requestor perspective, true
  # Else: send registration_required_notice for requestor organization
  def require_requestor_recipients!
    return true if memberships.requestor.any?
    send_registration_required_notice!
    false
  end

  def independent?
    return current_registration.independent? unless current_registration.blank?
    return registrations.joins { registration_term }.
      order { registration_terms.starts_at }.last.independent? unless registrations.empty?
    false
  end

  def name(format=nil)
    case format
    when :last_first
      "#{last_name}, #{first_name}"
    when :file
      name.downcase.gsub /[^\w]+/, '-'
    else
      "#{first_name} #{last_name}".strip.squeeze ' '
    end
  end

  def format_name
    return unless last_name
    self.first_name = "" unless first_name.class == String
    while match = last_name.match(/\A(Cornell|The|An|A)\s+(.*)\Z/) do
      self.first_name = "#{first_name} #{match[1]}".strip
      self.last_name = match[2]
    end
  end

  def to_s(format=nil)
    return super unless last_name
    name(format)
  end
end

