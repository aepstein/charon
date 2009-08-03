class DurableGoodExpense < ActiveRecord::Base
  belongs_to :version
  before_validation :calculate_total

	def calculate_total
		self.total = quantity * price
	end

	def max_request
	  total
  end

end

