module Pickle
  class Adapter
    class FactoryGirl < Adapter
      def initialize(factory)
        @klass, @name = factory.build_class, factory.name.to_s
      end

      def create(attrs = {})
        ::FactoryGirl.create(@name, attrs)
      end

      def self.factories
        factories = []
        ::FactoryGirl.factories.each {|v| factories << new(v)}
        factories
      end
    end
  end
end

