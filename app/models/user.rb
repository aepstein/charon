class User < ActiveRecord::Base
  include Fulfiller

  STATUSES = %w[ unknown undergrad grad staff faculty alumni temporary ]

  attr_protected :admin
  attr_readonly :net_id

  default_scope :order => 'users.last_name ASC, users.first_name ASC, users.middle_name ASC, users.net_id ASC'
  named_scope :approved, lambda { |approvable|
    { :joins => :approvals,
      :conditions => [ 'approvals.user_id = users.id AND approvable_type = ? AND approvable_id = ?',
      approvable.class.to_s, approvable.id ] }
  }
  scope_procedure :name_like, lambda { |name| first_name_or_middle_name_or_last_name_or_net_id_like(name) }

  acts_as_authentic do |c|
    c.login_field = 'net_id'
    c.validate_email_field = false
  end

  has_many :approvals do
    def agreements
      self.select { |approval| approval.approvable_type == 'Agreement' }
    end
    def requests
      self.select { |approval| approval.approvable_type == 'Request' }
    end
    def agreement_ids
      self.agreements.map(&:approvable_id)
    end
    def request_ids
      self.requests.map(&:approvable_id)
    end
  end
  has_many :fulfillments, :as => :fulfiller, :dependent => :delete_all do
    def requirements_sql
      fragments = inject([]) do |memo, fulfillment|
        memo << "(requirements.fulfillable_id = #{fulfillment.fulfillable_id} AND " +
        "requirements.fulfillable_type = #{connection.quote fulfillment.fulfillable_type})"
      end
      fragments.join ' OR '
    end
  end
  has_many :memberships, :dependent => :destroy
  has_many :roles, :through => :memberships, :conditions => [ 'memberships.active = ?', true ] do
    def in(organizations)
      proxy_owner.memberships.active.organization_id_equals_any( organizations.map(&:id) ).map(&:role)
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

  before_validation_on_create :extract_email, :initialize_password
  validates_inclusion_of    :status, :in => STATUSES
  before_validation :import_simple_ldap_attributes
  before_validation_on_create { |user| user.addresses.each { |address| address.addressable = user } }
  after_save :import_complex_ldap_attributes, 'Fulfillment.fulfill self'
  after_update 'Fulfillment.unfulfill self'

  def requests; Request.organization_id_equals_any( organization_ids ); end

  def request_ids; requests.map(&:id); end

  def initialize_password
    reset_password if password.blank?
  end

  def user_status_criterions
    UserStatusCriterion.all.select { |criterion| criterion.statuses.include? status }
  end

  def agreements
    Agreement.find( approvals.approvable_type_eq('Agreement').map { |approval| approval.approvable_id } )
  end

  def full_name
    "#{first_name} #{middle_name} #{last_name}".squeeze ' '
  end

  def name
    "#{first_name} #{last_name}".squeeze ' '
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
      self.first_name = ldap_entry.first_name.titleize unless ldap_entry.first_name.nil?
      self.middle_name = ldap_entry.middle_name.titleize unless ldap_entry.middle_name.nil?
      self.last_name = ldap_entry.last_name.titleize unless ldap_entry.last_name.nil?
      self.status = ldap_entry.status unless ldap_entry.status.nil?
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
end

