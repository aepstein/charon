class SpeakerExpense < ActiveRecord::Base
  belongs_to :version
	before_validation :calculate_total

  def calculate_total
    self.tax_exempt_expenses = mileage_cost + car_rental + basic_lodging_cost + additional_lodging_cost + meals_cost
  end

  def mileage_cost
    0.585 * mileage * number_of_speakers
  end

  def basic_lodging_cost
    75 * number_of_speakers * nights_of_lodging
  end

  def additional_lodging_cost
    10 * (number_of_speakers - 1) * nights_of_lodging
  end

  def meals_cost
    30 * number_of_speakers * nights_of_lodging
  end

	def max_request
	  tax_exempt_expenses
  end

end

