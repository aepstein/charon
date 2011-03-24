class SpeakerExpense < ActiveRecord::Base
  belongs_to :edition, :inverse_of => :speaker_expense

  validates_presence_of :edition
  validates_presence_of :title
  validates_numericality_of :distance, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :number_of_travelers, :only_integer => true, :greater_than => 0
  validates_numericality_of :nights_of_lodging, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :engagement_fee, :greater_than_or_equal_to => 0

  def travel_cost
    return 0.0 unless distance && number_of_travelers
    Charon::Application.app_config['expenses']['speaker']['travel'] * distance * number_of_travelers
  end

  def basic_lodging_cost
    return 0.0 unless number_of_travelers && nights_of_lodging
    Charon::Application.app_config['expenses']['speaker']['lodging'] * number_of_travelers * nights_of_lodging
  end

  def meals_cost
    return 0.0 unless number_of_travelers && nights_of_lodging
    Charon::Application.app_config['expenses']['speaker']['meals'] * number_of_travelers * nights_of_lodging
  end

	def max_request
	  return 0.0 unless engagement_fee
    engagement_fee + travel_cost + basic_lodging_cost + meals_cost
  end

end

