class RequestItem < ActiveRecord::Base
  belongs_to :requestable, :polymorphic => true
  belongs_to :request_node
  belongs_to :request
  acts_as_tree
  accepts_nested_attributes_for :requestable
end

