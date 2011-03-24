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
  validate :fulfillable_must_be_fulfillable_for_fulfiller

  def self.quoted_types_for(fulfiller)
    FULFILLABLE_TYPES[fulfiller.class.to_s].map { |type| connection.quote type }.join ','
  end

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

  def self.fulfill( subject )
    return subject.fulfill if FULFILLABLE_TYPES.keys.include? subject.class.to_s
    fulfill_fulfillable subject if FULFILLABLE_TYPES.values.flatten.include? subject.class.to_s
  end

  def self.unfulfill( subject )
    return subject.unfulfill if FULFILLABLE_TYPES.keys.include? subject.class.to_s
    unfulfill_fulfillable subject if FULFILLABLE_TYPES.values.flatten.include? subject.class.to_s
  end

  def fulfillable_must_be_fulfillable_for_fulfiller
    return unless fulfiller_type && fulfillable_type
    unless self.class.fulfiller_type_for_fulfillable( fulfillable_type ) == fulfiller_type
      errors.add :fulfillable_type, "not allowed for #{fulfiller_type}"
    end
  end

end

