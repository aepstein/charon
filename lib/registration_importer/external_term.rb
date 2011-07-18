module RegistrationImporter
  class ExternalTerm < ActiveRecord::Base

    include RegistrationImporter

    MAP = {
      :term_id        => :external_id,
      :term_ldescr    => :description,
      :current        => :current,
      :reg_start_time => :starts_at,
      :reg_end_time   => :ends_at
    }
    REGISTRATION_TERM_ATTRIBUTES = [ :term_ldescr, :current, :reg_start_time, :reg_end_time ]

    establish_connection "external_registrations_#{::Rails.env}".to_sym
    set_table_name "terms"
    set_primary_key :term_id
    default_scope :select => MAP.keys.join(', ')

    has_many :registrations, :class_name => 'ExternalRegistration', :foreign_key => :term_id do
      def latest
        latest = Registration.unscoped.where {
          external_term_id == my { proxy_owner.term_id } && when_updated != nil
          }.maximum(:when_updated)
        if latest
          return where( :updated_time.gt => latest )
        end
        ExternalRegistration.where( "orgs.term_id = #{proxy_owner.term_id}" )
      end
    end

    def current
      read_attribute( :current ) == 'YES'
    end

    def reg_start_time
      return nil if read_attribute(:reg_start_time).blank?
      Time.zone.at read_attribute(:reg_start_time)
    end

    def reg_end_time
      return nil if read_attribute(:reg_end_time).blank?
      Time.zone.at read_attribute(:reg_end_time)
    end

    def self.import
      adds, changes, starts = 0, 0, Time.now
      ExternalTerm.all.each do |source|
        destination = RegistrationTerm.find_or_initialize_by_external_id( source.term_id )
        destination.attributes = source.import_attributes( REGISTRATION_TERM_ATTRIBUTES )
        adds += 1 if destination.new_record?
        changes += 1 if destination.changed?
        destination.save if destination.changed?
      end
      d = RegistrationTerm.unscoped
      if ExternalTerm.all.length > 0
        d = d.where( 'external_id NOT IN (?)', ExternalTerm.all.map(&:term_id) )
      end
      deletes = d.map(&:destroy).length
      [adds, (changes - adds), deletes, ( Time.now - starts )]
    end

  end
end

