class RequestItem < ActiveRecord::Base
  belongs_to :requestable, :polymorphic => true
  belongs_to :request_node
  belongs_to :request

end

