class Requirement < ActiveRecord::Base
  belongs_to :permission
  belongs_to :fulfillable, :polymorphic => true

  validates_presence_of :permission
  validates_presence_of :fulfillable
end

