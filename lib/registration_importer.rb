module RegistrationImporter
  module ClassMethods

  end

  module InstanceMethods

    def import_attributes_for_local
      out = Hash.new
      MAP.each_pair do |key, value|
        out[value] = send(key) if send("#{key}?")
      end
      out
    end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

