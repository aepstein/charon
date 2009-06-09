class RequestItem < ActiveRecord::Base
  belongs_to :requestable, :polymorphic => true
  belongs_to :request_node
  belongs_to :request

  acts_as_tree
  acts_as_list :scope => :parent_id
end

