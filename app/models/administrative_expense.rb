class AdministrativeExpense < ActiveRecord::Base
  has_one :version, :as => :requestable
	before_save :calculate_total

	def calculate_total
		self.copies_expense = 0.03 * copies
		self.total = copies_expense + repairs_restocking + mailbox_wsh
	end

	def max_request
	  total
  end

end

