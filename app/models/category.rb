class Category < ActiveRecord::Base
  has_many :nodes

  validates_presence_of :name
  validates_uniqueness_of :name

  default_scope :order => "categories.name ASC"

  def to_s; name; end
end

