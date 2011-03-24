class ActivityReport < ActiveRecord::Base

  belongs_to :organization, :inverse_of => :activity_reports

  default_scope :include => [ :organization ],
    :order => 'organizations.last_name ASC, organizations.first_name ASC, ' +
    'activity_reports.starts_on ASC, activity_reports.description ASC'

  scope :past, lambda { where 'activity_reports.ends_on < ?', Time.zone.today }
  scope :current, lambda { where(
    'activity_reports.starts_on <= :date AND activity_reports.ends_on >= :date',
    :date => Date.today ) }
  scope :future, lambda { where 'activity_reports.starts_on > ?', Time.zone.today }
  scope :organization_name_contains, lambda { |name|
    where( 'organizations.last_name LIKE :n OR organizations.first_name LIKE :n',
      :n => "%#{name}%" )
  }

  search_methods :organization_name_contains

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

