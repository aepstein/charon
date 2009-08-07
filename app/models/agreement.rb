class Agreement < ActiveRecord::Base
  include GlobalModelAuthorization

  has_and_belongs_to_many :permissions
  has_many :approvals, :as => :approvable
  has_many :users, :through => :approvals

  validates_uniqueness_of :name
  validates_presence_of :name
  validates_presence_of :content

  def approve!
  end

  def unapprove!
  end

  def may_approve?(user)
    true
  end

  def may_unapprove?(user)
    false
  end

  def may_unapprove_other?(user)
    false
  end
end

