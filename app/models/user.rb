class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.login_field = 'net_id'
  end
  STATUSES = %w[ unknown undergrad grad staff faculty alumni temporary ]
  has_many :memberships,
           :include => [ :organization, :role ],
           :dependent => :destroy
  has_many :roles, :through => :memberships do
    def in(organizations)
      proxy_owner.memberships.active.in(organizations.map { |o| o.id } ).map { |m| m.role }
    end
  end
  has_many :registrations, :through => :memberships
  has_many :addresses, :as => :addressable, :dependent => :destroy do
    def by_label(label)
      self.select { |a| a.label == label}[0]
    end
    def create_or_update_from_attributes(attributes)
      return false unless attributes[:label]
      return self.create(attributes) if old = self.by_label(attributes[:label]).nil?
      old.update_attributes(attributes)
      old
    end
  end
  validates_presence_of     :net_id
  validates_uniqueness_of   :net_id
  before_validation_on_create :extract_email
  validates_inclusion_of    :status, :in => STATUSES
  before_save :import_simple_ldap_attributes
  before_update :import_complex_ldap_attributes
  after_create :import_complex_ldap_attributes

  def officer_in?(organization)
    (roles.in(organization) & Role.officer_roles).size > 0
  end

  def finance_officer_in?(organization)
    (roles.in(organization) & Role.finance_officer_roles).size > 0
  end


protected
  def extract_email
    self.email = "#{self.net_id}@cornell.edu"
  end

  def ldap_entry
    return nil if @ldap_entry == false
    begin
      @ldap_entry ||= DirectoryImporter::Record.find net_id
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

