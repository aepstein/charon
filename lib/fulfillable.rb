module Fulfillable

  module ClassMethods

    def is_fulfillable( fulfiller_type )
      class_eval <<-RUBY
        def self.fulfiller_type; "#{fulfiller_type}"; end
        def self.fulfiller_class; #{fulfiller_type.classify}; end

        has_many :fulfillments, as: :fulfillable, dependent: :delete_all do
          def fulfill!
            values = [ "#{self}", proxy_association.owner.id, Time.zone.now,
              "#{fulfiller_type}" ]
            values.map! { |v| connection.quote v }
            select_sql = proxy_association.owner.fulfiller_#{fulfiller_type.underscore.pluralize}.
              addable.except(:select).select( values.join( ', ' ) +
              ", `#{fulfiller_type.underscore.pluralize}`.`id`" ).to_sql
            connection.insert(
              "INSERT INTO fulfillments ( fulfillable_type, fulfillable_id, " +
              "created_at, fulfiller_type, fulfiller_id ) \#{select_sql}"
            )
            proxy_association.reset
            proxy_association.owner.association(
              :fulfiller_#{fulfiller_type.underscore.pluralize} ).proxy.reset
          end

          def unfulfill!
            where { fulfiller_type.eq( '#{fulfiller_type}' ) }.
            where { |f| f.fulfiller_id.not_in( proxy_association.owner.
              fulfiller_#{fulfiller_type.underscore.pluralize}.qualifying.
              select { id } ) }.delete_all
            proxy_association.reset
            proxy_association.owner.association(
              :fulfiller_#{fulfiller_type.underscore.pluralize} ).proxy.reset
          end
        end

        has_many :fulfiller_#{fulfiller_type.underscore.pluralize},
          through: :fulfillments, source: :fulfiller,
          source_type: "#{fulfiller_type}" do
            # Which fulfillers qualify
            def qualifying
              proxy_association.owner.class.fulfiller_class.unscoped.
              fulfill_#{self.to_s.underscore} proxy_association.owner
            end

            # Which fulfillers qualify, but not in fulfillments
            def addable
              qualifying.where { |f| f.id.not_in( scoped.select { id } ) }
            end

            # Which fulfiller in fulfillments, but no longer qualify
            def deletable
              scoped.where { |f| f.id.not_in( qualifying.select { id } ) }
            end
          end
       RUBY

      after_save { |fulfillable| fulfillable.fulfillments.fulfill! }
      after_update { |fulfillable| fulfillable.fulfillments.unfulfill! }

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

