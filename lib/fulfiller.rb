module Fulfiller

  module ClassMethods

    def is_fulfiller
      has_many :fulfillments, :as => :fulfiller, :dependent => :delete_all do
        # Register fulfillment for all the criteria met by this actor
        def fulfill
          Fulfillment::FULFILLABLE_TYPES[ proxy_owner.class.to_s ].each do |fulfillable_type|
            current = where( :fulfillable_type => fulfillable_type ).map(&:fulfillable_id)
            proxy_owner.send(fulfillable_type.underscore.pluralize).each do |criterion|
              fulfillments.create!( :fulfillable => criterion ) unless current.include?( criterion.id )
            end
          end
        end

        # Remove fulfillments for all criteria no longer met by this actor
        def unfulfill
          Fulfillment::FULFILLABLE_TYPES[ proxy_owner.class.to_s ].each do |fulfillable_type|
            current = proxy_owner.send( fulfillable_type.underscore.pluralize ).map( &:id )
            delete where( :fulfillable_type => fulfillable_type ).
              reject { |f| current.include? f.fulfillable_id }
          end
        end
      end

      cattr_accessor :fulfillable_types
      self.fulfillable_types = Fulfillment::FULFILLABLE_TYPES[ to_s ]

      cattr_accessor :quoted_fulfillable_types
      self.quoted_fulfillable_types = Fulfillment::FULFILLABLE_TYPES[ to_s ].
        map { |type| connection.quote type }.join ','

      after_save { |fulfiller| fulfiller.fulfillments.fulfill }
      after_update { |fulfiller| fulfiller.fulfillments.unfulfill }

      send :include, InstanceMethods
    end

  end

  module InstanceMethods

    # Identify frameworks for which all requirements are fulfilled by this actor
    def frameworks( perspective, role_ids = nil )
      Framework.fulfilled_for( self, perspective, role_ids )
    end

    # Identify framework ids for which all requirements are fulfilled by this actor
    def framework_ids( perspective, role_ids = nil )
      frameworks( perspective, role_ids ).map(&:id).uniq
    end

    def fulfilled_requirements( requirements )
      f = Fulfillment.arel_table
      requirements.with_inner_fulfillments.
        where( f[:fulfiller_id].eq( id ) ).
        where( f[:fulfiller_type].eq( self.class.to_s ) )
    end

    def unfulfilled_requirements( requirements )
      r = Requirement.arel_table
      f = Fulfillment.arel_table
      requirements.group( r[:id] ).with_fulfillments.unfulfilled.
        joins( "AND " + f[:fulfiller_id].eq( id ).
          and( f[:fulfiller_type].eq( self.class.to_s ) ).to_sql )
    end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
#    receiver.send :include, InstanceMethods
  end

end

