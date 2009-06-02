class AdministrativeExpense < ActiveRecord::Base
	before_save :calculate_total

	def calculate_total
		copies_expense = 0.03 * copies
		# total_request should be <= total
		total = copies_expense + repairs_restocking + mailbox_wsh
	end
end
