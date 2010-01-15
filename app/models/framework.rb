class Framework < ActiveRecord::Base
  include GlobalModelAuthorization

  default_scope :order => 'frameworks.name ASC'

  has_many :approvers
  has_many :permissions

  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s
    name
  end
end

