class FundAllocation < ActiveRecord::Base
  attr_accessible :amount, :fund_item, :fund_request_id
  attr_readonly :fund_item_id, :fund_request_id

  belongs_to :fund_item, inverse_of: :fund_allocations
  belongs_to :fund_request, inverse_of: :fund_allocations

  validates :amount,
    numericality: { greater_than_or_equal_to: 0.0 }
  validates :fund_item, presence: true
  validates :fund_request, presence: true

  scope :final, lambda { where { fund_request_id.in(
    FundRequest.unscoped.with_state(:allocated).select { id } ) } }
  scope :pending, lambda { where { fund_request_id.not_in(
    FundRequest.unscoped.with_state(:allocated).select { id } ) } }
  scope :for_category, lambda { |category| joins { fund_item }.
    where { |i| i.fund_item.node_id.in( Node.unscoped.select { id }.
      where { |n| n.category_id.eq( category.id ) } ) } }
end

