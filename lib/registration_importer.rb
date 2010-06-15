module RegistrationImporter
  module ClassMethods

  end

  module InstanceMethods

    def import_attributes( set )
      set.inject({}) do |memo, ( source, destination )|
        memo[destination] = send(source) if send("#{source}?")
        memo
      end
    end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

