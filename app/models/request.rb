class Request < ActiveRecord::Base
  belongs_to :basis
  has_many :items do
    def children_of(request_item)
      self.select { |item| item.parent_id == request_item.id }
    end
    def root
      self.select { |item| item.parent_id.nil? }
    end
  end
  has_and_belongs_to_many :organizations

  attr_readonly :basis_id
end

