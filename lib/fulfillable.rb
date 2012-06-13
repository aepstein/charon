module Fulfillable

  module ClassMethods

    def is_fulfillable( fulfiller_type )
      class_eval <<-RUBY
        def self.fulfiller_type; "#{fulfiller_type}"; end
        def self.fulfiller_class; #{fulfiller_type.classify}; end
       RUBY

      has_many :requirements, as: :fulfillable, dependent: :destroy
      has_many :frameworks, through: :requirements, uniq: true do
        def update!
          each { |framework| framework.memberships.update! }
        end
      end

      after_update 'frameworks.update!'
      after_destroy 'frameworks.update!'


      class << self
      end

      send :include, InstanceMethods
    end

  end

  module InstanceMethods
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
#    receiver.send :include, InstanceMethods
  end

end

