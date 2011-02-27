class UniversityAccount < ActiveRecord::Base
  include OrganizationNameLookup

  has_many :activity_accounts
  belongs_to :organization

  default_scope order( 'university_accounts.department_code ASC, ' +
    'university_accounts.subledger_code ASC').includes( :organization )

  scope :organization_name_contains, lambda { |name|
    includes( :organization ) & Organization.name_contains( name )
  }

  validates_format_of :department_code, :with => /\A[A-Z]\d{2,2}\Z/
  validates_format_of :subledger_code, :with => /\A\d{4,4}\Z/
  validates_uniqueness_of :subledger_code, :scope => [ :department_code ]
  validates_presence_of :organization

  before_validation do |r|
    r.department_code = r.department_code.capitalize unless r.department_code.blank?
  end

  def to_s; "#{department_code}-#{subledger_code}"; end
end

