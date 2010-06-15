module RegistrationImporter
  class ExternalTerm < ActiveRecord::Base
    MAP = {
      :term_id        => :external_id,
      :term_ldescr    => :description,
      :current        => :current,
      :reg_start_time => :starts_at,
      :reg_end_time   => :ends_at
    }

    establish_connection :external_registrations
    set_table_name "terms"
    set_primary_key :term_id
    default_scope :select => MAP.keys.join(', ')

    has_many :registrations, :class_name => 'ExternalRegistration', :foreign_key => :term_id

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
      ExternalTerm.all.each do |term|

      end
    end

  end
end

