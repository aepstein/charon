class User < ActiveRecord::Base
  STATUSES = %w[ undergrad grad staff faculty alumni temporary ]

  attr_accessible :password, :password_confirmation, :email, :first_name,
    :middle_name, :last_name, :date_of_birth, :addresses_attributes
  attr_accessible :admin, :net_id, :status, :as => :admin
  attr_readonly :net_id

  default_scope order( 'users.last_name ASC, users.first_name ASC, ' +
    'users.middle_name ASC, users.net_id ASC' )
  scope :approved, lambda { |approvable|
    joins( :approvals ).
    where( 'approvals.user_id = users.id AND approvable_type = ? AND approvable_id = ?',
      approvable.class.to_s, approvable.id )
  }
  scope :not_approved, lambda { |approvable|
    where( "users.id NOT IN ( SELECT user_id FROM approvals WHERE " +
      "approvable_type = ? AND approvable_id = ? )", approvable.class.to_s,
      approvable.id )
  }
  scope :name_contains, lambda { |name|
    sql = %w( first_name middle_name last_name net_id ).map do |field|
      "users.#{field} LIKE :name"
    end
    where( sql.join(' OR '), :name => "%#{name}%" )
  }

  search_methods :name_contains

  is_fulfiller

  acts_as_authentic do |c|
    c.login_field = 'net_id'
    c.validate_email_field = false
  end

  has_many :approvals, :inverse_of => :user do
    def agreements
      self.select { |approval| approval.approvable_type == 'Agreement' }
    end
    def fund_requests
      self.select { |approval| approval.approvable_type == 'FundRequest' }
    end
    def agreement_ids
      self.agreements.map(&:approvable_id)
    end
    def fund_request_ids
      self.fund_requests.map(&:approvable_id)
    end
  end
  has_many :memberships, :dependent => :destroy, :inverse_of => :user
  has_many :roles, :through => :memberships, :conditions => [ 'memberships.active = ?', true ] do
    def in(organizations)
      Membership.where( :user_id => @association.owner.id,
        :organization_id.in => organizations.map(&:id) ).active.map(&:role)
    end
    def requestor_in?(organization)
      requestor_in_ids( organization ).length > 0
    end
    def reviewer_in?(organization)
      reviewer_in_ids( organization ).length > 0
    end
    def requestor_in_ids(organization)
      ids_in_perspective organization, 'requestor'
    end
    def reviewer_in_ids(organization)
      ids_in_perspective organization, 'reviewer'
    end
    def ids_in_perspective( organization, perspective )
      names = case perspective
      when 'requestor'
        Role::REQUESTOR
      when 'reviewer'
        Role::REVIEWER
      else
        raise ArgumentError, 'perspective not allowed'
      end
      self.in( [organization] ).select { |r| names.include? r.name }.map(&:id)
    end
  end
  has_many :organizations, :through => :memberships, :conditions => [ 'memberships.active = ?', true ]
  has_many :registrations, :through => :memberships
  has_many :addresses, :as => :addressable, :dependent => :destroy do
    def by_label(label)
      self.select { |a| a.label == label}[0]
    end

    def create_or_update_from_attributes(attributes)
      return false unless attributes[:label]
      old = self.by_label(attributes[:label])
      return self.create(attributes) if old.nil?
      old.update_attributes(attributes)
      old
    end
  end

  accepts_nested_attributes_for :addresses, :allow_destroy => true,
     :reject_if => proc { |address| address[:street].blank? }

  validates_presence_of :net_id
  validates_uniqueness_of :net_id
  validates_format_of :email, :with => Authlogic::Regex.email

  before_validation :extract_email, :initialize_password, :initialize_addresses, :on => :create
  validates_inclusion_of :status, :in => STATUSES, :allow_blank => true
  before_validation :import_simple_ldap_attributes
  after_save :import_complex_ldap_attributes

  def fund_requests; FundRequest.organization_id_equals_any( organization_ids ); end

  def fund_request_ids; fund_requests.map(&:id); end

  def initialize_password
    reset_password if password.blank?
  end

  # Returns the user status criterions that the user presently fulfills
  def user_status_criterions
    UserStatusCriterion.all.select { |criterion| criterion.statuses.include? status }
  end

  # Returns the agreements (and therefore agreement criteria) that the user
  # presently fulfills
  def agreements
    Agreement.find( approvals.where( :approvable_type => 'Agreement' ).map { |approval|
      approval.approvable_id
    } )
  end

  # What frameworks is the user eligible for?
  # * perspective: the perspective from which user is approaching
  # * organization: the organization on behalf of which the user is acting
  def frameworks( perspective, organization = nil )
    return super( perspective ) if organization.blank?
    Framework.fulfilled_for( perspective, organization, self )
  end

  def full_name
    "#{first_name} #{middle_name} #{last_name}".squeeze ' '
  end

  def name(format = nil)
    case format
    when :net_id
      "#{first_name} #{last_name} (#{net_id})".squeeze ' '
    else
      "#{first_name} #{last_name}".squeeze ' '
    end
  end

  def to_email
    "#{name} <#{email}>"
  end

  def role_symbols
    return [:admin,:user] if admin?
    [:user]
  end

  def to_s; name; end

  protected

  def extract_email
    self.email = "#{net_id}@cornell.edu" if net_id && net_id_changed? && ( email.nil? || email.blank? )
  end

  def ldap_entry=(ldap_entry)
    @ldap_entry = ldap_entry
  end

  def ldap_entry
    return nil if @ldap_entry == false
    begin
      @ldap_entry ||= CornellLdap::Record.find net_id
    rescue Exception
      @ldap_entry = false
    end
  end

  def import_simple_ldap_attributes
    if ldap_entry then
      self.first_name = ldap_entry.first_name.titleize if ldap_entry.first_name
      self.middle_name = ldap_entry.middle_name.titleize if ldap_entry.middle_name
      self.last_name = ldap_entry.last_name.titleize if ldap_entry.last_name
      self.status = ldap_entry.status if ldap_entry.status
    end
  end

  def import_complex_ldap_attributes
    return if ldap_entry.nil?
    { 'campus' => ldap_entry.campus_address,
      'local' => ldap_entry.local_address,
      'home' => ldap_entry.home_address }.each do |label, address|
      addresses.create_or_update_from_attributes address.merge({:label => label}) if address
    end
  end

  def initialize_addresses
    addresses.each { |address| address.addressable = self }
  end
end

