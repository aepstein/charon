class Fulfillment < ActiveRecord::Base
  belongs_to :fulfiller, :polymorphic => true
  belongs_to :fulfilled, :polymorphic => true
end

