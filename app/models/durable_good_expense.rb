class DurableGoodExpense < ActiveRecord::Base
  attr_accessible :description, :quantity, :price
  attr_readonly :edition_id

  belongs_to :edition, :inverse_of => :durable_good_expense

  validates_presence_of :edition
  validates_numericality_of :price, :greater_than => 0
  validates_numericality_of :quantity, :greater_than => 0
  validates_presence_of :description

	def max_request
	  return 0.0 unless quantity && price
		quantity * price
  end

  def title; description; end

end

