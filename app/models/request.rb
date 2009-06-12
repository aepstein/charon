class Request < ActiveRecord::Base
  belongs_to :request_structure
  has_many :request_items

  accepts_nested_attributes_for :request_items, :allow_destroy => true
end

