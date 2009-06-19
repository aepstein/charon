class User < ActiveRecord::Base
 acts_as_authentic do |c|
   c.validate_email_field = false
   c.login_field = 'net_id'
 end
 STATUSES = %w[ unknown undergrad grad staff faculty alumni temporary ]
  has_many :memberships,
           :dependent => :destroy
  has_many :roles
  validates_presence_of     :net_id
  validates_uniqueness_of   :net_id
  before_validation_on_create :extract_email
=begin
  validates_inclusion_of    :status, :in => STATUSES

  before_create :import_simple_ldap_attributes
=end
  def login!
    update_attribute :last_login_at, Time.now
  end

  def may_be_updated_by?(user)
    return true if user==self
    false
  end

  def may_be_created_by?(user)
    false
  end

  def may_be_destroyed_by?(user)
    false
  end

  def may_be_shown_to?(user)
    user==self
  end

  def may_create?(resource)
    return resource.may_be_created_by?(self) unless is_admin?
    true
  end

  def may_update?(resource)
    return resource.may_be_updated_by?(self) unless is_admin?
    true
  end

  def may_destroy?(resource)
    return resource.may_be_destroyed_by?(self) unless is_admin?
    true
  end

  def may_see?(resource)
    return resource.may_be_shown_to?(self) unless is_admin?
    true
  end

  # TODO: Add superuser flag so any user can be designated for admin
  # privileges
  def is_admin?
    true
  end

  protected
    def extract_email
      self.email = "#{self.net_id}@cornell.edu"
    end

=begin
  def ldap_entry
    return nil if @ldap_entry == false
    begin
      @ldap_entry ||= CornellDirectoryImporter::Record.find net_id
    rescue Exception
      @ldap_entry = false
    end
  end

    def import_simple_ldap_attributes
      if ldap_entry then
        self.first_name = ldap_entry.first_name unless ldap_entry.first_name.nil?
        self.middle_name = ldap_entry.middle_name unless ldap_entry.middle_name.nil?
        self.last_name = ldap_entry.last_name unless ldap_entry.last_name.nil?
        self.status = ldap_entry.status unless ldap_entry.status.nil?
      end
    end
=end
   end

