class User < ActiveRecord::Base
  SEARCHABLE = [ :name_contains ]
  STATUSES = %w[ undergrad grad staff faculty alumni temporary ]

  attr_accessible :password, :password_confirmation, :email, :first_name,
    :middle_name, :last_name, :date_of_birth, :addresses_attributes,
    :as => [ :admin, :default ]
  attr_accessible :admin, :staff, :net_id, :status, as: :admin

  default_scope order { [ last_name, first_name, middle_name, net_id ] }
  scope :fulfill_user_status_criterion, lambda { |criterion|
    where { |u| u.status.in(
      (0..User::STATUSES.length).select { |i| ( 2**i & criterion.statuses_mask ) > 0 }.
      map { |i| User::STATUSES[i] }
    ) }
  }
  scope :fulfill_agreement, lambda { |agreement| approved( agreement ) }

  scope :approved, lambda { |approvable|
    where { |u| u.id.in(
      Approval.unscoped.with_approvable(approvable).select { user_id } ) }
  }
  scope :not_approved, lambda { |approvable|
    where { id.not_in(
      Approval.unscoped.with_approvable(approvable).select { user_id } ) }
  }
  scope :name_contains, lambda { |name|
    where {
      %w( first_name middle_name last_name net_id ).
      map { |f| instance_eval(f).like( "%#{name}%" ) }.inject(&:|) |
      CONCAT(first_name,' ',last_name).like( "%#{name}%" ) }
  }
  scope :admin, where( admin: true )
  scope :staff, where( staff: true )

  is_fulfiller 'UserStatusCriterion', 'Agreement'
  is_authenticable

  has_many :approvals, inverse_of: :user, dependent: :destroy
  has_many :approved_agreements, through: :approvals, source: :approvable,
    source_type: 'Agreement'
  has_many :approved_fund_requests, through: :approvals, source: :approvable,
    source_type: 'FundRequest'
  has_many :memberships, dependent: :destroy, inverse_of: :user
  has_many :roles, through: :memberships,
    conditions: [ 'memberships.active = ?', true ] do
    def in(organizations)
      Membership.where( :user_id => proxy_association.owner.id,
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
  has_many :organizations, through: :memberships, uniq: true,
    conditions: [ 'memberships.active = ?', true ]
  has_many :registrations, through: :memberships
  has_many :addresses, as: :addressable, dependent: :destroy do
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

  accepts_nested_attributes_for :addresses, allow_destroy: true,
     reject_if: proc { |address| address['street'].blank? }

  validates :net_id, presence: true, uniqueness: true
  validates :email, presence: true
  validates :status, inclusion: { in: STATUSES, allow_blank: true }

  before_validation :extract_email, :initialize_addresses, on: :create
  before_validation :import_simple_ldap_attributes
  after_save :import_complex_ldap_attributes
  after_update 'update_frameworks if status_changed?'

  def unapproved_agreements
    Agreement.where { |a| a.id.not_in( approved_agreements.select { id } ) }
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
    return [:staff,:user] if staff?
    [:user]
  end

  def to_s; name; end

  def refresh; save if updated_at < ( Time.zone.now - 1.month ); end

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
      addresses.create_or_update_from_attributes address.merge({label: label}) if address
    end
  end

  def initialize_addresses
    addresses.each { |address| address.addressable = self }
  end

end

