class Node < ActiveRecord::Base
  has_many :items
  belongs_to :structure
  acts_as_tree
end

