class UniversityAccount < ActiveRecord::Base
  include OrganizationNameLookup

  attr_accessible :account_code, :subaccount_code, :organization_name, :active

  belongs_to :organization, inverse_of: :university_accounts

  default_scope order { [ account_code, subaccount_code ] }

  scope :organization_name_contains, lambda { |name|
    joins { organization }.merge( Organization.unscoped.name_contains( name ) )
  }

  validates :account_code, presence: true
  validates :subaccount_code, presence: true, format: { with: /\A\d{5,5}\Z/ },
    uniqueness: { scope: :account_code }
  validates :organization, presence: true

  before_validation do |r|
    r.account_code = r.account_code.capitalize unless r.account_code.blank?
  end

#  ransacker :organization_name_contains

  def to_s; "#{account_code}-#{subaccount_code}"; end
end

