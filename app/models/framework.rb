class Framework < ActiveRecord::Base
  include GlobalModelAuthorization

  has_many :approvers
  has_many :permissions

  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s
    name
  end
end

