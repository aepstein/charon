class DurableGoodExpense < ActiveRecord::Base
  attr_accessible :description, :quantity, :price
  attr_readonly :fund_edition_id

  belongs_to :fund_edition, :inverse_of => :durable_good_expense

  has_paper_trail :class_name => 'SecureVersion'

  validates :fund_edition, :presence => true
  validates :price, :numericality => { :greater_than => 0 }
  validates :quantity, :numericality => { :greater_than => 0 }
  validates :description, :presence => true

	def max_fund_request
	  return 0.0 unless quantity && price
		quantity * price
  end

  def title; description; end

end

