class LocalEventExpense < ActiveRecord::Base
  attr_accessible :start_date, :end_date, :title, :location, :purpose,
    :number_of_attendees, :price_per_attendee, :copies_quantity,
    :uup_required, :accessibility_considered
  attr_readonly :fund_edition_id

  belongs_to :fund_edition, inverse_of: :local_event_expense

  has_paper_trail class_name: 'SecureVersion'

  validates :fund_edition, presence: true
	validates :start_date, timeliness: { type: :date }
	validates :end_date, timeliness: { type: :date,
	  greater_than_or_equal_to: :start_date }
	validates :title, presence: true
	validates :location, presence: true
	validates :purpose, presence: true
	validates :number_of_attendees,
	  numericality: { greater_than: 0, only_integer: true }
	validates :price_per_attendee,
	  numericality: { greater_than_or_equal_to: 0 }
  validates :copies_quantity,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  delegate :fund_request, to: :fund_edition

  def copies_cost
    return 0.0 unless copies_quantity
    Charon::Application.app_config['expenses']['general']['copies'] * copies_quantity
  end

  def revenue
    return 0.0 unless number_of_attendees && price_per_attendee
    price_per_attendee * number_of_attendees
  end

	def max_fund_request
	  copies_cost
  end

end

