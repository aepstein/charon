class FundAllocation < ActiveRecord::Base
  attr_accessible :amount
  attr_readonly :fund_item_id, :fund_request_id

  belongs_to :fund_item, inverse_of: :fund_allocations
  belongs_to :fund_request, inverse_of: :fund_allocations

  validates :amount,
    numericality: { greater_than_or_equal_to: 0.0 }
  validates :state, presence: true
  validates :fund_item, presence: true
  validates :fund_request, presence: true
end

