class RequestStructure < ActiveRecord::Base
  has_many :request_nodes do
    def children_of(request_node)
      self.select { |item| item.parent_id == request_node.id }
    end
    def root
      self.select { |item| item.parent_id.nil? }
    end
  end
  has_many :requests
end

