class Category < ActiveRecord::Base
  attr_accessible :name

  has_many :nodes, :inverse_of => :category
  has_many :activity_accounts, :inverse_of => :category

  validates_presence_of :name
  validates_uniqueness_of :name

  default_scope order( "categories.name ASC" )

  def to_s; name; end
end

