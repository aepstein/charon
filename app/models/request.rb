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
  accepts_nested_attributes_for :items, :allow_destroy => true
end

