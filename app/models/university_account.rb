class UniversityAccount < ActiveRecord::Base
  include OrganizationNameLookup

  attr_accessible :department_code, :subledger_code, :subaccount_code,
    :organization_name, :active

  has_many :activity_accounts, :inverse_of => :university_account, :dependent => :destroy
  belongs_to :organization, :inverse_of => :university_accounts

  default_scope order( 'university_accounts.department_code ASC, ' +
    'university_accounts.subledger_code ASC, ' +
    'university_accounts.subaccount_code ASC' )

  scope :organization_name_contains, lambda { |name|
    joins { organization }.merge( Organization.unscoped.name_contains( name ) )
  }

  validates_format_of :department_code, :with => /\A[A-Z]\d{2,2}\Z/
  validates_format_of :subledger_code, :with => /\A\d{4,4}\Z/
  validates_format_of :subaccount_code, :with => /\A\d{5,5}\Z/
  validates_uniqueness_of :subaccount_code, :scope => [ :department_code, :subledger_code ]
  validates_presence_of :organization

  before_validation do |r|
    r.department_code = r.department_code.capitalize unless r.department_code.blank?
  end

#  ransacker :organization_name_contains

  def to_s; "#{department_code}#{subledger_code}-#{subaccount_code}"; end
end

