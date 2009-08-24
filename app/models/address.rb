class Address < ActiveRecord::Base
  belongs_to :addressable, :polymorphic => true

  validates_presence_of :addressable
  validates_presence_of :label
  validates_uniqueness_of :label, :scope => [:addressable_id, :addressable_type]

  def may_create?(user)
    addressable.may_update? user
  end

  def may_update?(user)
    addressable.may_update? user
  end

  def may_destroy?(user)
    addressable.may_update? user
  end

  def may_see?(user)
    addressable.may_see? user
  end
end

