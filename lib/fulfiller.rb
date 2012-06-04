module Fulfiller

  module ClassMethods

    def is_fulfiller(*fulfillable_types)
      unless defined? fulfillments
        cattr_accessor :fulfillable_types
        has_many :fulfillments, as: :fulfiller, dependent: :delete_all do
          def fulfill!(*fulfillable_types)
            fulfillable_types = ( fulfillable_types.empty? ?
              proxy_association.owner.class.fulfillable_types : fulfillable_types )
            fulfillable_types.each { |t| fulfill_type! t }
            proxy_association.reset
          end
          def fulfill_type!(fulfillable_type)
            proxy_association.owner.send("fulfillable_#{fulfillable_type.underscore.pluralize}").
            addable.each do |fulfillable|
              self.create! fulfillable: fulfillable
            end
            reset_fulfillable_type fulfillable_type
          end
          def unfulfill!(*fulfillable_types)
            fulfillable_types = ( fulfillable_types.empty? ?
              proxy_association.owner.class.fulfillable_types : fulfillable_types )
            # Remove all fulfillments in single query
            deletes = fulfillable_types.map { |fulfillable_type|
              proxy_association.owner.
              send("fulfillable_#{fulfillable_type.underscore.pluralize}").
              deletable.map { |f| [f.class.to_s, f.id] }
            }.inject(:+)
            if deletes.any?
              scoped.where { |f| deletes.map { |i|
                f.fulfillable_type.eq( i.first ) & f.fulfillable_id.eq( i.last ) }.
              inject(&:|) }.delete_all
              fulfillable_types.each { |t| reset_fulfillable_type t }
              proxy_association.reset
            end
          end
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

