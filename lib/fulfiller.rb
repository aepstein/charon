module Fulfiller

  module ClassMethods

    def is_fulfiller(*fulfillable_types)
      unless defined? fulfillments
        attr_accessor :skip_update_frameworks
        cattr_accessor :fulfillable_types
        self.fulfillable_types = []
      end

      self.fulfillable_types += fulfillable_types

      send :include, InstanceMethods
    end

  end

  module InstanceMethods

    def update_frameworks
      return true if skip_update_frameworks || Framework.skip_update_frameworks
      memberships.each { |membership| membership.frameworks.update! }
      true
    end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
  end

end

