module Fulfillable

  module ClassMethods

    def is_fulfillable( fulfiller_type )
      class_eval <<-RUBY
        def self.fulfiller_type; "#{fulfiller_type}"; end
        def self.fulfiller_class; #{fulfiller_type.classify}; end
       RUBY

      has_many :requirements, as: :fulfillable, dependent: :destroy
      has_many :frameworks, through: :requirements, uniq: true

      after_update :update_frameworks
      around_destroy :update_frameworks

      class << self
      end

      send :include, InstanceMethods
    end

  end

  module InstanceMethods
    def update_frameworks(&block)
      if block
        frameworks = self.frameworks.all
        yield
      else
        frameworks = self.frameworks
      end
      frameworks.each { |framework| framework.update_memberships }
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
#    receiver.send :include, InstanceMethods
  end

end

