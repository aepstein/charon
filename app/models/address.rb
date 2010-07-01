class Address < ActiveRecord::Base
  belongs_to :addressable, :polymorphic => true

  attr_readonly :label

  validates_presence_of :addressable
  validates_presence_of :label
  validates_uniqueness_of :label, :scope => [:addressable_id, :addressable_type]

end

