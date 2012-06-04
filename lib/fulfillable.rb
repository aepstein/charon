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

#      has_many :fulfillments, as: :fulfillable, dependent: :delete_all do
#        def fulfill!
#          proxy_association.owner.
#        end

#        # Identify all the records that fulfill this condition and register
#        # fulfillments where they do not exist
#        def fulfill!
#          quoted_ft = connection.quote proxy_association.owner.class.fulfiller_type
#          underscore_ft = proxy_association.owner.class.fulfiller_type.underscore
#          fulfiller_ids = proxy_association.owner.send(underscore_ft + "_ids")
#          return true if fulfiller_ids.empty?
#          q_fulfillable_type = connection.quote proxy_association.owner.class.to_s
#          plural_ft = underscore_ft.pluralize
#          connection.insert(
#            "INSERT INTO fulfillments (fulfillable_type, fulfillable_id, " +
#            "fulfiller_type, created_at, fulfiller_id) " +
#            "SELECT #{q_fulfillable_type}, #{proxy_association.owner.id}, #{quoted_ft}, " +
#            "#{connection.quote Time.zone.now}, #{plural_ft}.id " +
#            "FROM #{plural_ft} LEFT JOIN fulfillments ON " +
#            "fulfillments.fulfiller_id = #{plural_ft}.id " +
#            "AND fulfillments.fulfiller_type = #{quoted_ft} AND " +
#            "fulfillments.fulfillable_type = #{q_fulfillable_type} " +
#            "AND fulfillments.fulfillable_id = #{proxy_association.owner.id} " +
#            "WHERE fulfillments.fulfiller_id IS NULL AND #{plural_ft}.id IN " +
#            "(#{fulfiller_ids.join ','})"
#          )
#          proxy_association.reset
#        end

#        # Identify all the records that do not fulfill this condition and
#        # delete their fulfillments
#        def unfulfill!
#          q_fulfillable_type = connection.quote proxy_association.owner.class.to_s
#          underscore_ft = proxy_association.owner.class.fulfiller_type.underscore
#          fulfiller_ids = proxy_association.owner.send(underscore_ft + '_ids')
#          connection.delete(
#            "DELETE FROM fulfillments WHERE fulfillable_type = " +
#            "#{q_fulfillable_type} AND fulfillable_id = #{proxy_association.owner.id}" +
#            (fulfiller_ids.empty? ? "" : " AND fulfiller_id NOT IN " +
#            "(#{fulfiller_ids.join ','})")
#          )
#          proxy_association.reset
#        end
#      end

      after_save { |fulfillable| fulfillable.fulfillments.fulfill! }
      after_update { |fulfillable| fulfillable.fulfillments.unfulfill! }

      class << self
#        def fulfiller_type
#          Fulfillment::FULFILLABLE_TYPES.each do |fulfiller_type, fulfillable_types|
#            return fulfiller_type if fulfillable_types.include?( to_s )
#          end
#          nil
#        end
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

