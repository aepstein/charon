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
    self.table_name = "terms"
    self.primary_key = "term_id"
    default_scope select( MAP.keys )

    has_many :registrations, class_name: 'ExternalRegistration', foreign_key: :term_id do
      def latest
        latest = Registration.unscoped.
        where { |r| r.external_term_id.eq( proxy_association.owner.term_id ) }.
        where { when_updated.not_eq( nil ) }.
        maximum(:when_updated)
        if latest
          return where { |e| e.updated_time.gt( latest ) }
        end
        ExternalRegistration.where { |e| e.term_id.eq( proxy_association.owner.term_id ) }
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
      Framework.skip_update_frameworks do
        adds, changes, starts = 0, 0, Time.now
        all.each do |source|
          destination = RegistrationTerm.find_or_initialize_by_external_id( source.term_id )
          destination.attributes = source.import_attributes( REGISTRATION_TERM_ATTRIBUTES )
          adds += 1 if destination.new_record?
          if destination.new_record? || destination.changed_significantly?
            changes += 1; destination.save!
          end
        end
        d = RegistrationTerm.unscoped
        if count > 0
          d = d.where { |r| r.external_id.not_in( all.map(&:term_id) ) }
        end
        deletes = d.map(&:destroy).length
        [adds, (changes - adds), deletes, ( Time.now - starts )]
      end
    end

  end
end

