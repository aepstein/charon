class Category < ActiveRecord::Base
  has_many :nodes

  validates_presence_of :name
  validates_uniqueness_of :name

  include GlobalModelAuthorization

  def to_s
    name
  end
end

