class Fulfillment < ActiveRecord::Base
  belongs_to :fulfiller, :polymorphic => true
  belongs_to :condition, :polymorphic => true
end

