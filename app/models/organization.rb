class Organization < ActiveRecord::Base
  SEARCHABLE = [ :name_contains ]
  attr_accessible :organization_profile_attributes
  attr_accessible :first_name, :last_name,
    :organization_profile_attributes, :member_sources_attributes, as: :admin

  notifiable_events :registration_required
  is_fulfiller

  has_one :organization_profile, inverse_of: :organization,
    dependent: :destroy
  has_many :activity_reports, dependent: :destroy, inverse_of: :organization
  has_many :activity_accounts, through: :university_accounts
  has_many :fund_grants, dependent: :destroy, inverse_of: :organization
  has_many :fund_requests, through: :fund_grants
  has_many :fund_sources, inverse_of: :organization do
    #  What fund sources is this organization eligible to start a grant for?
    # * must have an open deadline (submit_at is in the future)
    # * must fulfill criteria for user
    # * must not have a prior grant created
    def allowed_for( user )
      no_fund_grant.open_deadline_for_first.
        fulfilled_for( FundEdition::PERSPECTIVES.first, proxy_association.owner, user )
    end

    def unfulfilled_for( user )
      no_fund_grant.open_deadline_for_first.
        unfulfilled_for( FundEdition::PERSPECTIVES.first, proxy_association.owner, user )
    end

    def released
      FundSource.where { |s| s.id.in( proxy_association.owner.fund_grants.
        where { id.in( FundRequest.unscoped.released.select { fund_grant_id } ) }.
        select { fund_source_id } ) }
    end

    # For what sources has no grant been created for this organization?
    def no_fund_grant
      FundSource.no_fund_grant_for( proxy_association.owner )
    end
  end
  has_many :inventory_items, dependent: :destroy, inverse_of: :organization
  has_many :memberships, dependent: :destroy, inverse_of: :organization
  has_many :member_sources, inverse_of: :organization
  has_many :registrations, dependent: :nullify, inverse_of: :organization do
    def current
      select { |registration| registration.current? }.first
    end
  end
  has_many :roles, through: :memberships do
    def user_id_equals( id )
      scoped.where( 'memberships.user_id = ?', id )
    end
    def ids_for_user( user )
      user_id_equals( user.id ).all.map(&:id)
    end
  end
  has_many :university_accounts, dependent: :destroy, inverse_of: :organization
  has_many :users, through: :memberships,
    conditions: { memberships: { active: true } } do
    # What users do not fulfill the set of requirements?
    def unfulfilled_for( requirements )
      m = Membership.arel_table
      r = requirements.arel_table
      f = Fulfillment.arel_table
      scoped.group( m[:user_id] ).joins("INNER JOIN requirements").merge(
        requirements.with_fulfillments.unfulfilled.
        joins( "AND " + f[:fulfiller_id].eq( m[:user_id] ).
          and(  f[:fulfiller_type].eq( 'User' ) ).to_sql )
      ).
      where( m[:role_id].eq( r[:role_id] ).to_sql )
    end
    # What users do fulfill requirements?
    def fulfilled_for( requirements )
      m = Membership.arel_table
      r = requirements.arel_table
      f = Fulfillment.arel_table
      scoped.group( m[:user_id] ).joins("LEFT JOIN requirements ON " +
        m[:role_id].eq( r[:role_id] ).to_sql ).merge(
        requirements.with_fulfillments.fulfilled.
        joins( "AND " + f[:fulfiller_id].eq( m[:user_id] ).
          and(  f[:fulfiller_type].eq( 'User' ) ).to_sql )
      )
    end
  end
  belongs_to :last_current_registration, class_name: 'Registration'
  has_many :last_current_users, through: :last_current_registration,
    source: :users

  accepts_nested_attributes_for :organization_profile, update_only: true
  accepts_nested_attributes_for :member_sources, allow_destroy: true,
    reject_if: :all_blank

  before_validation :format_name

  default_scope order( 'organizations.last_name ASC, organizations.first_name ASC' )

  scope :name_contains, lambda { |name|
    sql = %w( first_name last_name ).inject([]) do |memo, field|
      memo << "organizations.#{field} LIKE :name"
    end
    where( sql.join(' OR '), :name => "%#{name}%" )
  }

  #search_methods :name_contains

  validates :last_name, :presence => true,
    :uniqueness => { :scope => [ :first_name ] }

  def frameworks( perspective, user = nil )
    return super( perspective ) if user.blank?
    Framework.fulfilled_for perspective, self, user
  end

  def registration_criterions
    return [] unless registrations.current
    registrations.current.registration_criterions
  end

  def registration_criterion_ids
    registration_criterions.map( &:id )
  end

  def registered?
    return false if registrations.current.blank?
    registrations.current.registered?
  end

  # Checks whether requestor recipients are present as active members
  # If at least one active membership is present in requestor perspective, true
  # Else: send registration_required_notice for requestor organization
  def require_requestor_recipients!
    return true if users.where( 'memberships.role_id IN ( SELECT id FROM roles ' +
      'WHERE name IN (?) )', Role::REQUESTOR ).any?
    send_registration_required_notice!
    false
  end

  def independent?
    return registrations.current.independent? unless registrations.current.blank?
    return registrations.joins { registration_term }.last(:order => 'registration_terms.starts_at ASC').independent? unless registrations.empty?
    false
  end

  def name(format=nil)
    case format
    when :last_first
      "#{last_name}, #{first_name}"
    when :file
      name.downcase.gsub /[^\w]+/, '-'
    else
      first_name? ? "#{first_name} #{last_name}" : last_name
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

