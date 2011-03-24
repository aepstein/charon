module Fulfillable

  module ClassMethods
  end

  module InstanceMethods

    # Identify all the records that fulfill this condition and register
    # fulfillments where they do not exist
    def fulfill
      quoted_ft = connection.quote fulfiller_type
      underscore_ft = fulfiller_type.underscore
      fulfiller_ids = send(underscore_ft + "_ids")
      return true if fulfiller_ids.empty?
      q_fulfillable_type = connection.quote self.class.to_s
      plural_ft = underscore_ft.pluralize
      connection.insert(
        "INSERT INTO fulfillments (fulfillable_type, fulfillable_id, " +
        "fulfiller_type, created_at, fulfiller_id) " +
        "SELECT #{q_fulfillable_type}, #{id}, #{quoted_ft}, " +
        "#{connection.quote Time.zone.now}, #{plural_ft}.id " +
        "FROM #{plural_ft} LEFT JOIN fulfillments ON " +
        "fulfillments.fulfiller_id = #{plural_ft}.id " +
        "AND fulfillments.fulfiller_type = #{quoted_ft} AND " +
        "fulfillments.fulfillable_type = #{q_fulfillable_type} " +
        "AND fulfillments.fulfillable_id = #{id} " +
        "WHERE fulfillments.fulfiller_id IS NULL AND #{plural_ft}.id IN " +
        "(#{fulfiller_ids.join ','})"
      )
      fulfillments.reset
    end

    # Identify all the records that do not fulfill this condition and
    # delete their fulfillments
    def unfulfill
      q_fulfillable_type = connection.quote self.class.to_s
      underscore_ft = fulfiller_type.underscore
      fulfiller_ids = send(underscore_ft + '_ids')
      connection.delete(
        "DELETE FROM fulfillments WHERE fulfillable_type = #{q_fulfillable_type} " +
        "AND fulfillable_id = #{id}" +
        (fulfiller_ids.empty? ? "" : " AND fulfiller_id NOT IN (#{fulfiller_ids.join ','})")
      )
      fulfillments.reset
    end

    # Identify the class that may fulfill this criterion
    def fulfiller_type
      Fulfillment::FULFILLABLE_TYPES.each do |fulfiller_type, fulfillable_types|
        return fulfiller_type if fulfillable_types.include? self.class.to_s
      end
      raise "Unknown fulfiller type for criterion of class #{self.class}"
    end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end

end

