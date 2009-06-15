class Request < ActiveRecord::Base
  has_many :request_items
  acts_as_tree
  accepts_nested_attributes_for :request_items
  accepts_nested_attributes_for :children
end

