class FundRequestType < ActiveRecord::Base
  attr_accessible :name, :allowed_for_first, :amendable_quantity_limit,
    :appendable_quantity_limit, :appendable_amount_limit, :quantity_limit

  has_and_belongs_to_many :fund_queues
  has_many :fund_requests, inverse_of: :fund_request_type,
    dependent: :destroy

  default_scope order { name }
  scope :allowed_for_first, where { allowed_for_first == true }

  validates :name, presence: true, uniqueness: true
  validates :amendable_quantity_limit,
    numericality: { only_integer: true, allow_nil: true,
      greater_than_or_equal_to: 0 }
  validates :appendable_quantity_limit,
    numericality: { only_integer: true, allow_nil: true,
      greater_than_or_equal_to: 0 }
  validates :appendable_amount_limit,
    numericality: { allow_nil: true, greater_than_or_equal_to: 0.0 }
  validates :quantity_limit, numericality: { allow_nil: true,
    only_integer: true, greater_than_or_equal_to: 0 }

  def to_s; name; end
end

