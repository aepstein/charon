class Role < ActiveRecord::Base
  include GlobalModelAuthorization

  default_scope :order => 'roles.name ASC'

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :memberships, :dependent => :destroy
  has_many :permissions, :dependent => :destroy

  def to_s
    name
  end
end

