class TravelEventExpense < ActiveRecord::Base
  belongs_to :version
	before_validation :calculate_total

  validates_presence_of :version
  validates_date :event_date
  validates_presence_of :event_title
  validates_presence_of :event_location
  validates_presence_of :event_purpose
  validates_numericality_of :members_per_group, :only_integer => true, :greater_than => 0
  validates_numericality_of :number_of_groups, :only_integer => true, :greater_than => 0
  validates_numericality_of :mileage, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :nights_of_lodging, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :per_person_fees, :greater_than_or_equal_to => 0
  validates_numericality_of :per_group_fees, :greater_than_or_equal_to => 0

  def calculate_total
    self.total_eligible_expenses = total_person_fees + total_group_fees + mileage_cost + lodging_cost
  end

  def participants
    return 0 unless members_per_group && number_of_groups
    members_per_group * number_of_groups
  end

  def total_person_fees
    return 0.0 unless per_person_fees
    participants * per_person_fees
  end

  def total_group_fees
    return 0.0 unless number_of_groups && per_group_fees
    number_of_groups * per_group_fees
  end

  def mileage_cost
    return 0.0 unless mileage
    0.05 * participants * mileage
  end

  def lodging_cost
    return 0.0 unless nights_of_lodging
    10 * participants * nights_of_lodging
  end

  def max_request
    total_eligible_expenses
  end

end

