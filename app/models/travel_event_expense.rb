class TravelEventExpense < ActiveRecord::Base
  attr_accessible :date, :title, :location, :purpose, :travelers_per_group,
    :number_of_groups, :distance, :nights_of_lodging, :per_person_fees,
    :per_group_fees
  attr_readonly :edition_id

  belongs_to :edition, :inverse_of => :travel_event_expense

  validates_presence_of :edition
  validates_date :date
  validates_presence_of :title
  validates_presence_of :location
  validates_presence_of :purpose
  validates_numericality_of :travelers_per_group, :only_integer => true, :greater_than => 0
  validates_numericality_of :number_of_groups, :only_integer => true, :greater_than => 0
  validates_numericality_of :distance, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :nights_of_lodging, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :per_person_fees, :greater_than_or_equal_to => 0
  validates_numericality_of :per_group_fees, :greater_than_or_equal_to => 0

  def participants
    return 0 unless travelers_per_group && number_of_groups
    travelers_per_group * number_of_groups
  end

  def total_person_fees
    return 0.0 unless per_person_fees
    participants * per_person_fees
  end

  def total_group_fees
    return 0.0 unless number_of_groups && per_group_fees
    number_of_groups * per_group_fees
  end

  def travel_cost
    return 0.0 unless distance
    Charon::Application.app_config['expenses']['travel']['travel'] * participants * distance
  end

  def lodging_cost
    return 0.0 unless nights_of_lodging
    Charon::Application.app_config['expenses']['travel']['lodging'] * participants * nights_of_lodging
  end

  def max_request
    total_person_fees + total_group_fees + travel_cost + lodging_cost
  end

end

