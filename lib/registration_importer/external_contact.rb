module RegistrationImporter
  class ExternalContact < ActiveRecord::Base

    include RegistrationImporter

    MAP = {
      :org_id      => :external_id,
      :term_id     => :external_term_id,
      :contacttype => :role,
      :title       => :title,
      :netid       => :net_id,
      :email       => :email,
      :firstname   => :first_name,
      :lastname    => :last_name
    }
    USER_ATTRIBUTES = [ :firstname, :lastname ]
    MEMBERSHIP_ATTRIBUTES = [ :contacttype ]
    ROLE_MAP = {
      'PRES' => 'president',
      'TRES' => 'treasurer',
      'OFFICER3' => 'officer',
      'OFFICER4' => 'officer',
      'ADVISOR' => 'advisor'
    }

    establish_connection "external_registrations_#{::Rails.env}".to_sym
    self.table_name = "orgs_contacts"
    self.primary_keys = [ :org_id, :term_id, :contacttype ]
    default_scope select( MAP.keys.join(', ') )

    belongs_to :term, :class_name => 'ExternalTerm', :foreign_key => :term_id

    def registration=(new_registration)
      self.org_id = new_registration.org_id
      self.term_id = new_registration.term_id
      @registration = new_registration
    end

    def registration
      return @registration = nil unless org_id? && term_id?
      @registration ||= ExternalRegistration.find(org_id, term_id)
    end

    def users
      net_ids.inject([]) do |memo, net_id|
        user = User.find_or_initialize_by_net_id( net_id )
        user.attributes = import_attributes( USER_ATTRIBUTES )
        user.save!
        memo << [ contacttype, user ]
      end
    end

    def contacttype
      role = Role.find_or_create_by_name ROLE_MAP[ read_attribute(:contacttype) ]
      role.new_record? ? nil : role
    end

    def net_ids
      "#{netid} #{email}".to_net_ids
    end

  end
end

