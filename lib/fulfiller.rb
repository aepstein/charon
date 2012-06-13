module Fulfiller

  module ClassMethods

    def is_fulfiller(*fulfillable_types)
      unless defined? fulfillments
        attr_accessor :skip_update_frameworks
        cattr_accessor :fulfillable_types
        self.fulfillable_types = []
        send :include, InstanceMethods
      end

      class_eval <<-RUBY
        scope :fulfill, lambda { |fulfillable|
          unless #{self.to_s}.fulfillable_types.include? fulfillable.class.to_s
            raise ArgumentError,
              "received \#{fulfillable.class} instead of " +
              "\#{#{self.to_s}.fulfillable_types.join ','}"
          end
          send( "fulfill_\#{fulfillable.class.to_s.underscore}", fulfillable )
        }
      RUBY

      self.fulfillable_types += fulfillable_types

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

