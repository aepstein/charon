class Registration < ActiveRecord::Base
  default_scope :order => "registrations.name, registrations.parent_id DESC"
  named_scope :active,
              :conditions => 'registrations.id NOT IN (SELECT parent_id FROM registrations)'
  named_scope :unmatched,
              :conditions => { :organization_id => nil }
  named_scope :named,
              lambda { |name|
                { :conditions => [ "registrations.name LIKE '%?%'", name ] }
              }
  named_scope :percent_members_of_type,
              lambda { |percent, type|
                { :conditions => [ " ? <= ( number_of_#{type.to_s} * 100.0 / ( " +
                                   "number_of_undergrads + number_of_grads + " +
                                   "number_of_staff + number_of_faculty + " +
                                   "number_of_others ) )", percent.to_i] }
              }
  acts_as_tree
  belongs_to :organization
  has_many :memberships, :dependent => :destroy do
    def with_role(role)
      self.select { |membership| membership.role_id == role.id }
    end
    # Synchronizes relational memberships with flat record
    # users is an array of users who should be in the role
    # role is a Role object
    def synchronize(users,role)
      self.with_role(role).each do |membership|
        if users.include?(membership.user)
          users.delete membership.user
          membership.organization = proxy_owner.organization if proxy_owner.organization_id_changed?
          membership.active = proxy_owner.active?
          membership.save if membership.changed?
        else
          self.delete membership
        end
      end
      users.each do |user|
        self.create( :user => user,
                     :role => role,
                     :organization => proxy_owner.organization,
                     :active => proxy_owner.active? )
      end
    end
  end
  has_many :users, :through => :memberships, :uniq => true do
    # Creates User records for each user identified for a particular prefix
    # in the flat records
    def for_prefix(prefix)
      users = Array.new
      attributes = proxy_owner.user_attributes_for_prefix(prefix)
      (attributes[:net_ids].to_net_ids +
       attributes[:emails].to_net_ids ).uniq.each do |net_id|
        user = User.find_or_initialize_by_net_id(net_id)
        if user.new_record?
          user.attributes = attributes
          user.save
        end
        users << user
      end
      users
    end
  end

  validates_uniqueness_of :id

  before_save :verify_parent_exists, :update_organization
  after_save :synchronize_memberships

  # Eliminates reference to parent registration if registration is not in
  # database.
  def verify_parent_exists
    parent_id = nil unless Registration.exists?(parent_id)
  end

  def update_organization
    organization.update_attributes(attributes_for_organization) if organization_id? && active?
  end

  # Synchronizes memberships associated with this registration
  # Eliminates memberships no longer asserted by the registration
  # Adds new memberships asserted by the registration
  # Touches parent if it still has active memberships
  # TODO: Keep in mind that as presently structured, each prefix must correspond
  # to a different role or some records will not be correctly synchronized.
  def synchronize_memberships
    Registration.prefix_map.each do |prefix, role|
      memberships.synchronize( users.for_prefix(prefix),
                               role )
    end
    parent.touch if parent_id? && parent.memberships.active.size > 0
  end

  def attributes_for_organization
    names = name.split(',')
    if names.size > 1
      { :first_name => names.pop.strip, :last_name => names.join(',') }
    else
      { :first_name => '', :last_name => names.pop }
    end
  end

  def active?
    children.empty?
  end

  def self.prefix_map
    @@prefix_map ||= {'pre' =>     Role.find_or_create_by_name('president'),
                      'vpre' =>    Role.find_or_create_by_name('vice-president'),
                      'tre' =>     Role.find_or_create_by_name('treasurer'),
                      'adv' =>     Role.find_or_create_by_name('advisor'),
                      'officer' => Role.find_or_create_by_name('officer') }
  end

  def to_s
    name
  end

  # Returns hash of officer information, including array of
  # net ids
  # TODO: Include email (but only if valid)
  def user_attributes_for_prefix(prefix)
    { :first_name => self["#{prefix}_first_name"] || '',
      :last_name => self["#{prefix}_last_name"] || '',
      :emails => self["#{prefix}_email"] || '',
      :net_ids => self["#{prefix}_net_id"] || ''}
  end

end

