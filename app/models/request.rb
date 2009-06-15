class Request < ActiveRecord::Base
  belongs_to :request_basis
  has_many :request_items do
    def children_of(request_item)
      self.select { |item| item.parent_id == request_item.id }
    end
    def root
      self.select { |item| item.parent_id.nil? }
    end
  end
  accepts_nested_attributes_for :request_items, :allow_destroy => true
end

