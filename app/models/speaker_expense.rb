class SpeakerExpense < ActiveRecord::Base
  belongs_to :version

  validates_presence_of :version
  validates_presence_of :speaker_name
  validates_date :performance_date
  validates_numericality_of :mileage, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :number_of_speakers, :only_integer => true, :greater_than => 0
  validates_numericality_of :nights_of_lodging, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :engagement_fee, :greater_than_or_equal_to => 0
  validates_numericality_of :car_rental, :greater_than_or_equal_to => 0

  def mileage_cost
    return 0.0 unless mileage && number_of_speakers
    0.585 * mileage * number_of_speakers
  end

  def basic_lodging_cost
    return 0.0 unless number_of_speakers && nights_of_lodging
    75 * number_of_speakers * nights_of_lodging
  end

  def additional_lodging_cost
    return 0.0 unless number_of_speakers && nights_of_lodging
    10 * (number_of_speakers - 1) * nights_of_lodging
  end

  def meals_cost
    return 0.0 unless number_of_speakers && nights_of_lodging
    30 * number_of_speakers * nights_of_lodging
  end

	def max_request
	  return 0.0 unless engagement_fee && car_rental
    engagement_fee + mileage_cost + car_rental + basic_lodging_cost + additional_lodging_cost + meals_cost
  end

end

