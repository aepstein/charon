module Fulfiller

  module ClassMethods
  end

  module InstanceMethods

    # Register fulfillment for all the criteria met by this actor
    def fulfill
      Fulfillment::FULFILLABLE_TYPES[ self.class.to_s ].each do |fulfillable_type|
        current = fulfillments.where( :fulfillable_type => fulfillable_type ).map(&:fulfillable_id)
        send(fulfillable_type.underscore.pluralize).each do |criterion|
          fulfillments.create!( :fulfillable => criterion ) unless current.include?( criterion.id )
        end
      end
    end

    # Remove fulfillments for all criteria no longer met by this actor
    def unfulfill
      Fulfillment::FULFILLABLE_TYPES[ self.class.to_s ].each do |fulfillable_type|
        current = send( fulfillable_type.underscore.pluralize ).map( &:id )
        logger.debug "Unfulfilling #{fulfillable_type} except with id #{current.join ','}"
        fulfillments.delete fulfillments.
          where( :fulfillable_type => fulfillable_type ).
          reject { |f| current.include? f.fulfillable_id }
      end
    end

    # Identify frameworks for which all requirements are fulfilled by this actor
    def frameworks( perspective, role_ids = nil )
      Framework.fulfilled_for( self, perspective, role_ids )
    end

    # Identify framework ids for which all requirements are fulfilled by this actor
    def framework_ids( perspective, role_ids = nil )
      frameworks( perspective, role_ids ).map(&:id)
    end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end

end

