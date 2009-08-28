class DurableGoodExpense < ActiveRecord::Base
  belongs_to :version
  before_validation :calculate_total

  validates_numericality_of :total, :greater_than => 0
  validates_numericality_of :price, :greater_than => 0
  validates_numericality_of :quantity, :greater_than => 0
  validates_presence_of :description
  validates_presence_of :version

	def calculate_total
	  return unless quantity && price
		self.total = quantity * price
	end

	def max_request
	  total
  end

end

