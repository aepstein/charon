class LocalEventExpense < ActiveRecord::Base
  attr_accessible :date, :title, :location, :purpose, :number_of_attendees,
    :price_per_attendee, :copies_quantity, :services_cost, :uup_required
  attr_readonly :edition_id

  belongs_to :edition, :inverse_of => :local_event_expense

  has_paper_trail :class_name => 'SecureVersion'

  validates :edition, :presence => true
	validates :date, :timeliness => { :type => :date }
	validates :title, :presence => true
	validates :location, :presence => true
	validates :purpose, :presence => true
	validates :number_of_attendees,
	  :numericality => { :greater_than => 0, :only_integer => true }
	validates :price_per_attendee,
	  :numericality => { :greater_than_or_equal_to => 0 }
  validates :copies_quantity,
    :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :services_cost,
    :numericality => { :greater_than_or_equal_to => 0 }

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

