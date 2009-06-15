class RequestNode < ActiveRecord::Base
  has_many :request_items
  belongs_to :request_structure
  acts_as_tree
end

