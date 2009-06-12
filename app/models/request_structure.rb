class RequestStructure < ActiveRecord::Base
  has_many :request_nodes
  has_many :requests
  has_many :request_items, :through => :request_nodes
end

