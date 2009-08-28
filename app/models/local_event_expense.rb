class LocalEventExpense < ActiveRecord::Base
  belongs_to :version
	before_validation :calculate_local_event_expense

  validates_presence_of :version
	validates_date :date_of_event
	validates_presence_of :title_of_event
	validates_presence_of :location_of_event
	validates_presence_of :purpose_of_event
	validates_numericality_of :anticipated_no_of_attendees, :greater_than => 0, :only_integer => true
	validates_numericality_of :admission_charge_per_attendee, :greater_than_or_equal_to => 0
  validates_numericality_of :number_of_publicity_copies, :only_integer => true
  validates_numericality_of :rental_equipment_services, :greater_than_or_equal_to => 0
  validates_numericality_of :copyright_fees, :greater_than_or_equal_to => 0
  validates_numericality_of :total_copy_rate, :greater_than_or_equal_to => 0
  validates_numericality_of :total_eligible_expenses, :greater_than_or_equal_to => 0
  validates_numericality_of :admission_charge_revenue, :greater_than_or_equal_to => 0
  validates_numericality_of :total_request_amount, :greater_than_or_equal_to => 0


	def calculate_local_event_expense
	  return unless number_of_publicity_copies && rental_equipment_services && total_copy_rate && copyright_fees &&
	    anticipated_no_of_attendees && admission_charge_per_attendee
		self.total_copy_rate = number_of_publicity_copies * 0.03
		self.total_eligible_expenses = rental_equipment_services + total_copy_rate + copyright_fees
		self.admission_charge_revenue = anticipated_no_of_attendees * admission_charge_per_attendee
		self.total_request_amount = total_eligible_expenses - admission_charge_revenue
  end

	def max_request
	  total_request_amount
  end

end

