module DirectoryImporter
  class Record < ActiveLdap::Base
#    establish_connection :cornell_directory
    ldap_mapping :dn_attribute => 'uid',
                 :prefix => 'ou=People'

    def status
      return @status unless @status.nil?
      return unless attribute_present?('type')
      @status = case self['type']
        when /^staff/ then 'staff'
        when /^acad/ then 'faculty'
        when /^student/ then case cornelleduacadcollege
          when 'AS', 'AR', 'AG', 'IL', 'HE', 'EN', 'UN' then 'undergrad'
          else 'grad'
        end
        when /^alumni/ then 'alumni'
        when /^temp/ then 'temporary'
        else 'unknown'
      end
    end

    def campus_address
      unless @campus_address.nil?
        return @campus_address
      end
      @campus_address = false unless attribute_present?('cornelleducampusaddress') &&
        @campus_address = { :street => cornelleducampusaddress,
                            :on_campus => true }
      return campus_address
    end

    def local_address
      unless @local_address.nil?
        return @local_address
      end
      @local_address = false unless attribute_present?('cornelledulocaladdress') &&
        @local_address = Record.make_address_attributes(cornelledulocaladdress)
      return local_address
    end

    def home_address
      unless @home_address.nil?
        return @home_address
      end
      @home_address = false unless attribute_present?('homePostalAddress') &&
        @home_address = Record.make_address_attributes(homePostalAddress)
      return home_address
    end

    # Takes an address string and converts it to a hash suitable for import into
    def self.make_address_attributes(string_address)
      return if string_address.nil?
      array_address = string_address.split(',').map! { |x| x.strip }
      state = false
      array_address.each_index { |i| state = i if array_address[i] =~ /^[A-Za-z]{2,2}$/ }
      return unless state && state > 1
      attributes = { :street => array_address[0..(state-2)].join(', '),
        :city => array_address[state - 1],
        :state => array_address[state] }
      attributes[:zip] = array_address[state + 1] unless array_address[state + 1].nil?
      attributes
    end

    def first_name
      return nil unless attribute_present?('givenName')
      self.givenName
    end

    def middle_name
      return nil unless attribute_present?('cornelledumiddlename')
      self.cornelledumiddlename
    end

    def last_name
      return nil unless attribute_present?('sn')
      self.sn
    end
  end
end
