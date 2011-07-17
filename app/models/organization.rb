class Organization < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :club_sport

  is_fulfiller

  has_many :activity_reports, :dependent => :destroy, :inverse_of => :organization
  has_many :activity_accounts, :through => :university_accounts
  has_many :fund_grants, :dependent => :destroy, :inverse_of => :organization
  has_many :fund_requests, :through => :fund_grants
  has_many :fund_sources, :inverse_of => :organization do
    def allowed_for( perspective, *fulfillers )
      FundSource.allowed_for( perspective, [ proxy_owner ] + fulfillers )
    end
    def no_fund_grant
      FundSource.no_fund_grant_for( proxy_owner )
    end
  end
  has_many :inventory_items, :dependent => :destroy, :inverse_of => :organization
  has_many :memberships, :dependent => :destroy, :inverse_of => :organization
  has_many :member_sources, :inverse_of => :organization
  has_many :registrations, :dependent => :nullify, :inverse_of => :organization do
    def current
      select { |registration| registration.current? }.first
    end
  end
  has_many :roles, :through => :memberships do
    def user_id_equals( id )
      scoped.where( 'memberships.user_id = ?', id )
    end
    def ids_for_user( user )
      user_id_equals( user.id ).all.map(&:id)
    end
  end
  has_many :university_accounts, :dependent => :destroy, :inverse_of => :organization
  has_many :users, :through => :memberships,
    :conditions => { :memberships => { :active => true } }

  before_validation :format_name

  default_scope order( 'organizations.last_name ASC, organizations.first_name ASC' )

  scope :name_contains, lambda { |name|
    sql = %w( first_name last_name ).inject([]) do |memo, field|
      memo << "organizations.#{field} LIKE :name"
    end
    where( sql.join(' OR '), :name => "%#{name}%" )
  }

  search_methods :name_contains

  validates :last_name, :presence => true,
    :uniqueness => { :scope => [ :first_name ] }

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

  def independent?
    return registrations.current.independent? unless registrations.current.blank?
    return registrations.last(:order => 'registration_terms.starts_at ASC').independent? unless registrations.empty?
    false
  end

  def name(format=nil)
    case format
    when :last_first
      "#{last_name}, #{first_name}"
    else
      first_name.blank? ? last_name : "#{first_name} #{last_name}"
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

  def to_s
    name
  end
end

