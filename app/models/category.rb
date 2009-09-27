class Category < ActiveRecord::Base
  has_many :nodes

  validates_presence_of :name
  validates_uniqueness_of :name

  default_scope :name, :order => "categories.name ASC"

  include GlobalModelAuthorization

  def to_s
    name
  end
end

