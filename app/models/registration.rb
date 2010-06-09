class Registration < ActiveRecord::Base
  MEMBER_TYPES = %w( undergrads grads staff faculty others )
  default_scope :order => "registrations.name ASC, registrations.parent_id DESC"
  named_scope :active, :joins => 'LEFT JOIN registrations AS r ON registrations.id = r.parent_id',
   :conditions => 'r.id IS NULL'
  named_scope :unmatched, :conditions => { :organization_id => nil }
  named_scope :named, lambda { |name|
    { :conditions => [ "registrations.name LIKE '%?%'", name ] }
  }
  named_scope :min_percent_members_of_type, lambda { |percent, type|
    { :conditions => [ " ? <= ( number_of_#{type.to_s} * 100.0 / ( " +
        "number_of_undergrads + number_of_grads + number_of_staff + number_of_faculty + " +
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
      net_ids_for_prefix(prefix).each do |net_id|
        user = User.find_or_initialize_by_net_id(net_id)
        if user.new_record?
          user.attributes = attributes_for_prefix(prefix)
          user.save
        end
        users << user
      end
      users
    end

    def attributes_for_prefix(prefix)
      { :first_name => proxy_owner.send("#{prefix}_first_name") || '',
        :last_name => proxy_owner.send("#{prefix}_last_name") || '',
        :password => 'secret',
        :password_confirmation => 'secret' }
    end

    def net_ids_for_prefix(prefix)
      net_ids = Array.new
      %w( email net_id ).each do |value|
        if proxy_owner.send("#{prefix}_#{value}?")
          net_ids += proxy_owner.send("#{prefix}_#{value}").to_net_ids
        end
      end
      net_ids.uniq
    end

  end

  validates_uniqueness_of :id

  before_save :verify_parent_exists, :update_organization
  after_save :synchronize_memberships, 'Fulfillment.fulfill organization if organization && active?'
  after_update 'Fulfillment.unfulfill organization if organization && active?'

  def registration_criterions
    RegistrationCriterion.all.inject([]) do |memo, criterion|
      memo << criterion if fulfills? criterion
      memo
    end
  end

  def fulfills?(criterion)
    return false if criterion.must_register? && !registered?
    percent_members_of_type(criterion.type_of_member) >= criterion.minimal_percentage
  end

  def percent_members_of_type(type)
    ( send('number_of_' + type) * 100.0 ) / ( number_of_undergrads +
      number_of_grads + number_of_staff + number_of_faculty + number_of_others )
  end

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

  def percent_members_of_type(type)
    self.send("number_of_#{type.to_s}") * 100.0 / ( number_of_undergrads +
      number_of_grads + number_of_staff + number_of_faculty + number_of_others )
  end

  def eligible_for?(framework)
    return false unless registered?
    if framework.member_percentage
      return percent_members_of_type(framework.member_percentage_type) >= framework.member_percentage
    else
      true
    end
  end

  def find_or_create_organization( params=nil )
    find_or_build_organization( params ).save if organization.nil? || organization.new_record?
    organization
  end

  def find_or_build_organization( params=nil )
    return organization unless organization.nil?
    params = Hash.new if params.nil?
    build_organization( params.merge( attributes_for_organization ) )
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

  def to_s; name; end

end

