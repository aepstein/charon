class Registration < ActiveRecord::Base
  has_one :organization, :dependent => :nullify
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
        else
          self.delete membership
        end
      end
      users.each do |user|
        self.create( :user => user,
                     :role => role,
                     :organization => proxy_owner.organization )
      end
    end
  end
  has_many :users, :through => :memberships, :uniq => true do
    # Creates User records for each user identified for a particular prefix
    # in the flat records
    def for_prefix(prefix)
      users = Array.new
      proxy_owner.fetch_user_attributes(prefix).each do |attributes|
        (attributes[:net_ids].to_net_ids +
         attributes[:emails].to_net_ids ).uniq.each do |net_id|
          user = User.find_or_initialize_by_net_id(net_id)
          if user.new_record?
            user.attributes = attributes
            user.save
          end
          users << user
        end
      end
      users
    end
  end
  validates_uniqueness_of :id

  after_save :synchronize_memberships

  # Synchronizes memberships associated with this registration
  # Eliminates memberships no longer asserted by the registration
  # Adds new memberships asserted by the registration
  # TODO: Keep in mind that as presently structured, each prefix must correspond
  # to a different role or some records will not be correctly synchronized.
  def synchronize_memberships
    self.prefix_map.each do |prefix, role|
      memberships.synchronize( users.for_prefix(prefix),
                               role )
    end
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

  # Find registrations which are not matched to a group, ordered by name
  def self.find_unmatched
    Registration.find( :all,
                          :conditions => [
                            "registrations.id NOT IN " +
                            "(SELECT registration_id " +
                            "FROM organizations)" ],
                          :order => :name )
  end

  protected
    # Returns hash of officer information, including array of
    # net ids
    # TODO: Include email (but only if valid)
    def fetch_user_attributes(pre)
      { :first_name => self["#{pre}_first_name"] || '',
        :last_name => self["#{pre}_last_name"] || '',
        :emails => self["#{pre}_email"] || '',
        :net_ids => self["#{pre}_net_id"] || ''}
    end

end

