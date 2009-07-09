class DurableGoodExpense < ActiveRecord::Base
  belongs_to :version

	def max_request
	  total
  end

end

