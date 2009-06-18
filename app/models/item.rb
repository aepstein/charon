class Item < ActiveRecord::Base
  belongs_to :requestable, :polymorphic => true
  belongs_to :node
  belongs_to :request
  acts_as_tree
  accepts_nested_attributes_for :requestable
end

