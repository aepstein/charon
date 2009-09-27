class LocalEventExpense < ActiveRecord::Base
  belongs_to :version

  validates_presence_of :version
	validates_date :date
	validates_presence_of :title
	validates_presence_of :location
	validates_presence_of :purpose
	validates_numericality_of :number_of_attendees, :greater_than => 0, :only_integer => true
	validates_numericality_of :price_per_attendee, :greater_than_or_equal_to => 0
  validates_numericality_of :copies_quantity, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :services_cost, :greater_than_or_equal_to => 0

  delegate :requestors, :to => :request
  delegate :request, :to => :version

  def copies_cost
    return 0.0 unless copies_quantity
    0.03 * copies_quantity
  end

  def revenue
    return 0.0 unless number_of_attendees && price_per_attendee
    price_per_attendee * number_of_attendees
  end

	def max_request
	  copies_cost + services_cost
  end

end

