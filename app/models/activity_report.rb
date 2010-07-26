class ActivityReport < ActiveRecord::Base
  named_scope :past, lambda { { :conditions => ['activity_reports.ends_on < ?', Date.today] } }
  named_scope :current, lambda { { :conditions => [
    'activity_reports.starts_on <= :date AND activity_reports.ends_on >= :date',
    { :date => Date.today } ] } }
  named_scope :future, lambda { { :conditions => ['activity_reports.starts_on > ?', Date.today] } }

  belongs_to :organization

  validates_presence_of :organization
  validates_presence_of :description
  validates_numericality_of :number_of_others, :integer_only => true,
    :greater_than_or_equal_to => 0
  validates_numericality_of :number_of_undergrads, :integer_only => true,
    :greater_than_or_equal_to => 0
  validates_numericality_of :number_of_grads, :integer_only => true,
    :greater_than_or_equal_to => 0
  validates_date :starts_on
  validates_date :ends_on, :on_or_after => :starts_on
end

