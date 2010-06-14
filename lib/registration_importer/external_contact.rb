module RegistrationImporter
  class ExternalContact < ActiveRecord::Base
    MAP = {
      :org_id      => :external_id,
      :term_id     => :external_term_id,
      :contacttype => :role_id,
      :title       => :title,
      :netid       => :net_id,
      :email       => :email,
      :firstname   => :first_name,
      :lastname    => :last_name
    }
    USER_ATTRIBUTES = [ :netid, :firstname, :lastname ]
    MEMBERSHIP_ATTRIBUTES = [ :contacttype ]
    ROLE_MAP = {
      'PRES' => 'president',
      'TRES' => 'treasurer',
      'OFFICER3' => 'officer',
      'OFFICER4' => 'officer',
      'ADVISOR' => 'advisor'
    }

    establish_connection :external_registrations
    set_table_name "orgs_contacts"
    set_primary_keys :org_id, :term_id, :contacttype
    default_scope :select => MAP.keys.join(', ')

    belongs_to :external_registration, :foreign_key => [ :org_id, :term_id ]

    def contacttype
      role = Role.find_or_create_by_name ROLE_MAP[ read_attribute(:contacttype) ]
      return nil if role.new_record?
      role.id
    end

  end
end

