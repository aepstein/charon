class Structure < ActiveRecord::Base
  has_many :nodes do
    def children_of(node)
      self.select { |n| n.parent_id == node.id }
    end
    def root
      self.select { |n| n.parent_id.nil? }
    end
  end
  has_many :requests
end

