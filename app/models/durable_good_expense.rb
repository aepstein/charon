class DurableGoodExpense < ActiveRecord::Base
  has_one :version, :as => :requestable

	def max_request
	  total
  end

end

