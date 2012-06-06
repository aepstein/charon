class ActivityReport < ActiveRecord::Base
  SEARCHABLE = [ :organization_name_contains, :description_contains ]

  attr_accessible :number_of_others, :number_of_undergrads, :number_of_grads,
    :description, :starts_on, :ends_on
  attr_readonly :organization_id

  belongs_to :organization, inverse_of: :activity_reports

  scope :ordered, includes { organization }.
    order( 'organizations.last_name ASC, organizations.first_name ASC, ' +
      'activity_reports.starts_on ASC, activity_reports.description ASC' )
  scope :past, lambda { where 'activity_reports.ends_on < ?', Time.zone.today }
  scope :current, lambda { where(
    'activity_reports.starts_on <= :date AND activity_reports.ends_on >= :date',
    :date => Time.zone.today ) }
  scope :future, lambda { where 'activity_reports.starts_on > ?', Time.zone.today }
  scope :organization_name_contains, lambda { |name|
    where( 'organizations.last_name LIKE :n OR organizations.first_name LIKE :n',
      :n => "%#{name}%" )
  }
  scope :description_contains, lambda { |content|
    where { |activity_reports| activity_reports.description =~ "%#{content}%" }
  }

  has_paper_trail class_name: 'SecureVersion'

  validates :organization, presence: true
  validates :description, presence: true
  validates :number_of_others, numericality: { integer_only: true,
    greater_than_or_equal_to: 0 }
  validates :number_of_undergrads, numericality: { integer_only: true,
    greater_than_or_equal_to: 0 }
  validates :number_of_grads, numericality: { integer_only: true,
    greater_than_or_equal_to: 0 }
  validates :starts_on, timeliness: { type: :date }
  validates :ends_on, timeliness: { type: :date,
    on_or_after: :starts_on }
end

