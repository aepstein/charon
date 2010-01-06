class Fulfillment < ActiveRecord::Base
  FULFILLABLE_TYPES = {
    'User' => %w( Agreement UserStatusCriterion ),
    'Organization' => %w( RegistrationCriterion )
  }

  belongs_to :fulfiller, :polymorphic => true
  belongs_to :fulfillable, :polymorphic => true

  validates_presence_of :fulfiller_type, :in => FULFILLABLE_TYPES.keys
  validates_presence_of :fulfiller
  validates_presence_of :fulfillable
  validates_uniqueness_of :fulfillable_id, :scope => [ :fulfillable_type, :fulfiller_id, :fulfiller_type ]

  def self.fulfiller_type_for_fulfillable(fulfillable)
    fulfillable_type = case fulfillable.class.to_s
    when 'String'
      fulfillable
    else
      fulfillable.class.to_s
    end
    FULFILLABLE_TYPES.each do |fulfiller_type, fulfillable_types|
      return fulfiller_type if fulfillable_types.include?(fulfillable_type)
    end
    nil
  end

  def self.fulfill( fulfillable )
    q_fulfillable_type = connection.quote fulfillable.class.to_s
    fulfiller_type = fulfiller_type_for_fulfillable fulfillable
    quoted_ft = connection.quote fulfiller_type
    underscore_ft = fulfiller_type.underscore
    plural_ft = underscore_ft.pluralize
    fulfiller_ids = fulfillable.send(underscore_ft + "_ids")
    unless fulfiller_ids.empty?
      connection.execute(
        "INSERT INTO fulfillments (fulfillable_type, fulfillable_id, fulfiller_type, created_at, fulfiller_id) " +
        "SELECT #{q_fulfillable_type}, #{fulfillable.id}, #{quoted_ft}, #{connection.quote DateTime.now.utc}, #{plural_ft}.id " +
        "FROM #{plural_ft} LEFT JOIN fulfillments ON fulfillments.fulfiller_id = #{plural_ft}.id " +
        "AND fulfillments.fulfiller_type = #{quoted_ft} " +
        "WHERE fulfillments.fulfiller_id IS NULL AND #{plural_ft}.id IN (#{fulfiller_ids.join(', ')})"
      )
      fulfillable.fulfillments.reload
    end
  end

  def self.unfulfill( fulfillable )
    q_fulfillable_type = connection.quote fulfillable.class.to_s
    underscore_ft = fulfiller_type_for_fulfillable(fulfillable).underscore
    connection.execute(
      "DELETE FROM fulfillments WHERE fulfillable_type = #{q_fulfillable_type} " +
      "AND fulfillable_id = #{fulfillable.id} AND " +
      "fulfiller_id NOT IN (#{fulfillable.send(underscore_ft + '_ids').join(', ')})"
    )
    fulfillable.fulfillments.reload
  end

  def fulfillable_must_be_fulfillable_for_fulfiller
    return unless fulfiller_type && fulfillable_type
    unless self.class.fulfiller_type_for_fulfillable( fulfillable_type ) == fulfiller_type
      errors.add :fulfillable_type, "not allowed for #{fulfiller_type}"
    end
  end
end

