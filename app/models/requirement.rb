class Requirement < ActiveRecord::Base
  belongs_to :permission
  belongs_to :fulfillable, :polymorphic => true

  validates_presence_of :permission
  validates_presence_of :fulfillable
  validates_uniqueness_of :permission_id, :scope => [ :fulfillable_id, :fulfillable_type ]
  validates_inclusion_of :fulfillable_type, :in => Fulfillment::FULFILLABLE_TYPES.values.flatten
end

