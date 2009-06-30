class AdministrativeExpense < ActiveRecord::Base
  has_one :version, :as => :requestable
	before_save :calculate_total

	def calculate_total
		self.copies_expense = 0.03 * copies.to_f
		self.total = copies_expense.to_f + repairs_restocking.to_f + mailbox_wsh.to_f
	end
end

