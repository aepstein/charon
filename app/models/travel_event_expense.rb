class TravelEventExpense < ActiveRecord::Base
  belongs_to :version
	before_validation :calculate_total

  def calculate_total
    self.total_eligible_expenses = total_person_fees + total_group_fees + mileage_cost + lodging_cost
  end

  def participants
    members_per_group * number_of_groups
  end

  def total_person_fees
    participants * per_person_fees
  end

  def total_group_fees
    number_of_groups * per_group_fees
  end

  def mileage_cost
    0.05 * participants * mileage
  end

  def lodging_cost
    10 * participants * nights_of_lodging
  end

  def max_request
    total_eligible_expenses
  end

end

