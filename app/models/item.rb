class Item < ActiveRecord::Base
  belongs_to :node
  belongs_to :request
  has_many :versions
  acts_as_tree
end

