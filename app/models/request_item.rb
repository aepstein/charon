class RequestItem < ActiveRecord::Base
  belongs_to :requestable, :polymorphic => true
  belongs_to :request_node
  belongs_to :request

  acts_as_list :scope => 'request_id = #{request_id} AND ' +
                         'request_node_id = #{request_node_id}'
end

