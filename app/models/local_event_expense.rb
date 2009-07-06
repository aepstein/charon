class LocalEventExpense < ActiveRecord::Base
  has_one :version, :as => :requestable
  before_save :calculate_local_event_expense

	def calculate_local_event_expense
		self.total_copy_rate = number_of_publicity_copies * 0.03
		self.total_eligible_Expenses = rental_equipment_services + total_copy_rate + copyright_fees
		self.admission_charge_revenue = anticipated_no_of_attendees * admission_charge_per_attendee
		self.total_request_amount = total_eligible_Expenses - admission_charge_revenue
  end

	def max_request
	  total_request_amount
  end

end

