class LocalEventExpense < ActiveRecord::Base
  attr_accessible :date, :title, :location, :purpose, :number_of_attendees,
    :price_per_attendee, :copies_quantity, :services_cost, :uup_required
  attr_readonly :edition_id

  belongs_to :edition, :inverse_of => :local_event_expense

  validates_presence_of :edition
	validates_date :date
	validates_presence_of :title
	validates_presence_of :location
	validates_presence_of :purpose
	validates_numericality_of :number_of_attendees, :greater_than => 0, :only_integer => true
	validates_numericality_of :price_per_attendee, :greater_than_or_equal_to => 0
  validates_numericality_of :copies_quantity, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :services_cost, :greater_than_or_equal_to => 0

  delegate :requestor, :to => :request
  delegate :request, :to => :edition

  def copies_cost
    return 0.0 unless copies_quantity
    Charon::Application.app_config['expenses']['general']['copies'] * copies_quantity
  end

  def revenue
    return 0.0 unless number_of_attendees && price_per_attendee
    price_per_attendee * number_of_attendees
  end

	def max_request
	  copies_cost + services_cost
  end

end

