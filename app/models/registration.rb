class Registration < ActiveRecord::Base
  has_one :organization, :dependent => :nullify
  has_many :memberships,
           :dependent => :destroy
  has_many :users, :through => :memberships, :uniq => true
  validates_uniqueness_of :org_id

  after_save :sync_members
  PREFIX_MAP = {'pre' =>     'president',
                'vpre' =>    'officer',
                'tre' =>     'treasurer',
                'adv' =>     'advisor',
                'officer' => 'officer' }

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

 alias_method :create_organization_without_people, :create_organization
  def create_organization_with_people(attrs = {})
    g = create_organization_without_people( HashWithIndifferentAccess.new(:name => self.name).merge(attrs) )
    self.users.each do |p|
      ( m = self.memberships.find_by_person_id(p) ).organization = self.organization
      m.save
    end if g && g.errors.empty?
    return g
  end

  alias_method :create_organization, :create_organization_without_people
protected
    # Returns hash of officer information, including array of
    # net ids
    # TODO: Include email (but only if valid)
    def fetch_officer_attributes(pre)
      { :first_name => self["#{pre}_first_name"] || '',
        :last_name => self["#{pre}_last_name"] || '',
        :email => self["#{pre}_email"] || '',
        :net_id => self["#{pre}_net_id"] || ''}
    end

    # For particular officer position:
    # * Identify associated net_ids
    # * Initialize person for each net_id
    # * If a new person must be created:
    # ** If there is only one net_id, seed name from attrs
    # ** Else there are multiple net_ids, seed names from LDAP
    # ** Save the new person
    # * Initialize membership by sao_registration_id/person_id/role_id
    # * Associate membership with this registration and group
    # * Save membership
    # * Return array of net_ids for which initialization was performed
    # TODO: unit test; appears to be okay
    def init_from_officer_attributes(pre)
      users = Array.new
      attrs = fetch_officer_attributes(pre)
      net_ids = attrs[:net_id].to_net_ids + attrs.delete(:email).to_net_ids
      net_ids.each do |net_id|
        p = Users.find_or_initialize_by_net_id(net_id)
        if p.new_record? then
          if net_ids.length == 1 then
            attrs[:net_id] = net_id
            p.update_attributes attrs
          else
            p["first_name"] = 'Unknown'
            p["last_name"] = 'Unknown'
          end #if attr[:net_id].length == 1
          p.save
        end #if p.new_record
        users.push p
      end #each
      return users
    end

    # Synchronize memberships table to assertions of this record
    # * Add newly asserted associations
    # * Remove memberships that are no longer asserted
    # * Added assertions and old assertions modified to reflect curent group match
    def sync_members
      new = self.get_sao_members_map
      old = self.get_local_members_map
      new.keys.each do |role|
        new[role].keys.each do |id|
          unless old[role][id]
            self.memberships.create :organization => self.organization, :person => new[role][id], :role => role
          end
        end
      end
      old.keys.each do |role|
        old[role].keys.each do |id|
          if new[role][id] then
            old[role][id].group = self.group
            old[role][id].save
          else
            old[role][id].destroy
          end
        end
      end
    end

    # Return hash of hashes of people objects indicating currently asserted
    # persons/roles of registration
    # * First level is role
    # * Second level is person.id
    # * Third level is person object
    def get_sao_members_map
      map = Hash.new
      PREFIX_MAP.keys.each do |pre|
        prefix = PREFIX_MAP[pre]
        unless map[prefix]
          map[prefix] = Hash.new
        end #unless
        self.init_from_officer_attributes(pre).each do |p|
          unless map[prefix][p["id"]]
            map[prefix][p["id"]] = p
          end #unless
        end #each
      end #each
      return map
    end #def

    # Return hash of hashes of current officers of the group
    # First level is office held [our standard, not SAO]
    # Second level is person.id
    # Third level is membership object
    def get_local_members_map
      map = Hash.new
      self.memberships.each do |membership|
        unless map[membership["role"]]
          map[membership["role"]] = Hash.new
        end
        unless map[membership["role"]][membership.person["id"]]
          map[membership["role"]][membership.person["id"]] = membership
        end
      end
      (PREFIX_MAP.values - map.keys).each do |role|
        map[role] = Hash.new
      end
      return map
    end
end

