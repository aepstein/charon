class SpeakerExpense < ActiveRecord::Base
  attr_accessible :title, :distance, :number_of_travelers, :nights_of_lodging,
    :engagement_fee, :dignitary
  attr_readonly :fund_edition_id

  belongs_to :fund_edition, inverse_of: :speaker_expense

  has_paper_trail class_name: 'SecureVersion'

  validates :fund_edition, presence: true
  validates :title, presence: true
  validates :distance,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :number_of_travelers,
    numericality: { only_integer: true, greater_than: 0 }
  validates :nights_of_lodging,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :engagement_fee,
    numericality: { greater_than_or_equal_to: 0 }

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

	def max_fund_request
	  return 0.0 unless engagement_fee
    engagement_fee + travel_cost + basic_lodging_cost + meals_cost
  end

end

