class Role < ActiveRecord::Base
  include GlobalModelAuthorization

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :memberships, :dependent => :destroy

  def to_s
    name
  end
end

