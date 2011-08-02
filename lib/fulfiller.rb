module Fulfiller

  module ClassMethods

    def is_fulfiller
      has_many :fulfillments, :as => :fulfiller, :dependent => :delete_all do
        # Register fulfillment for all the criteria met by this actor
        def fulfill!
          Fulfillment::FULFILLABLE_TYPES[ @association.owner.class.to_s ].each do |fulfillable_type|
            current = where( :fulfillable_type => fulfillable_type ).map(&:fulfillable_id)
            @association.owner.send(fulfillable_type.underscore.pluralize).each do |criterion|
              create!( :fulfillable => criterion ) unless current.include?( criterion.id )
            end
          end
        end

        # Remove fulfillments for all criteria no longer met by this actor
        def unfulfill!
          Fulfillment::FULFILLABLE_TYPES[ @association.owner.class.to_s ].each do |fulfillable_type|
            current = @association.owner.send( fulfillable_type.underscore.pluralize ).map( &:id )
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

      after_save { |fulfiller| fulfiller.fulfillments.fulfill! }
      after_update { |fulfiller| fulfiller.fulfillments.unfulfill! }

      send :include, InstanceMethods
    end

  end

  module InstanceMethods

    # Frameworks for which this fulfills all requirements
    # * does not look at role-limited requirements
    # * does not look at requirements the subject cannot directly fulfill
    def frameworks( perspective )
      Framework.fulfilled_for perspective, self
    end

    # Of the listed requirements, which ones does this fulfiller meet?
    # * only return requirements with fulfillments
    # * fulfillments must match fulfiller
    def fulfilled_requirements( requirements )
      f = Fulfillment.arel_table
      requirements.with_inner_fulfillments.
        where( f[:fulfiller_id].eq( id ) ).
        where( f[:fulfiller_type].eq( self.class.to_s ) )
    end

    # Of the listed requirements, which ones does this fulfiller not meet?
    # * return requirements without matching fulfillments
    # * fulfillments must be null or must match the fulfiller
    # * only return requirements with fulfillable type that fulfiller can fulfill
    def unfulfilled_requirements( requirements )
      r = Requirement.arel_table
      f = Fulfillment.arel_table
      requirements.group( r[:id] ).with_outer_fulfillments.unfulfilled.
        joins( "AND " + f[:fulfiller_id].eq( id ).
          and( f[:fulfiller_type].eq( self.class.to_s ) ).to_sql ).
        where( r[:fulfillable_type].in( self.class.fulfillable_types ) )
    end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
  end

end

