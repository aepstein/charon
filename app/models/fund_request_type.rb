class FundRequestType < ActiveRecord::Base
  attr_accessible :name, :allowed_for_first, :amendable_quantity_limit,
    :appendable_quantity_limit, :appendable_amount_limit

  has_and_belongs_to_many :fund_queues
  has_many :fund_requests, :inverse_of => :fund_request_type,
    :dependent => :destroy

  default_scope order { name }

  validates :name, :presence => true, :uniqueness => true
  validates :amendable_quantity_limit,
    :numericality => { :only_integer => true, :allow_nil => true,
      :greater_than_or_equal_to => 0 }
  validates :appendable_quantity_limit,
    :numericality => { :only_integer => true, :allow_nil => true,
      :greater_than_or_equal_to => 0 }
  validates :appendable_amount_limit,
    :numericality => { :allow_nil => true, :greater_than_or_equal_to => 0.0 }
end

