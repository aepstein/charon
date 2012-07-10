class Address < ActiveRecord::Base
  attr_accessible :label, :street, :city, :state, :zip, :on_campus,
    as: [ :admin, :default ]
  attr_readonly :addressable_id, :addressable_type, :label

  belongs_to :addressable, polymorphic: true

  validates :addressable, presence: true
  validates :label, presence: true,
    uniqueness: { scope: [ :addressable_id, :addressable_type ] }

end

