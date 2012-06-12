module Fulfiller

  module ClassMethods

    def is_fulfiller(*fulfillable_types)
      unless defined? fulfillments
        attr_accessor :skip_update_frameworks
        cattr_accessor :fulfillable_types
          def reset_fulfillable_type(fulfillable_type)
            proxy_association.owner.
            send(:association,
              "fulfillable_#{fulfillable_type.underscore.pluralize}".to_sym).
            reset
          end
        end
        self.fulfillable_types = []
      end

      fulfillable_types.each do |fulfillable_type|
        class_eval <<-RUBY
          has_many :fulfillable_#{fulfillable_type.underscore.pluralize},
          through: :fulfillments, source: :fulfillable,
          source_type: "#{fulfillable_type}" do
            def qualifying
              #{fulfillable_type}.unscoped.fulfilled_by proxy_association.owner
            end

            def addable
              qualifying.where { |f| f.id.not_in( scoped.select { id } ) }
            end

            def deletable
              scoped.where { |f| f.id.not_in( qualifying.select { id } ) }
            end
          end
        RUBY
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

