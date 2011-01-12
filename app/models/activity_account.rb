class ActivityAccount < ActiveRecord::Base
  belongs_to :university_account
  belongs_to :basis
  belongs_to :category

  scope :organization_id_equals, lambda { |id|
    joins(:university_account) & UniversityAccount.unscoped.where(:organization_id => id)
  }

  validates_presence_of :university_account
  validates_uniqueness_of :university_account_id, :scope => [ :basis_id, :category_id ]

  def organization; university_account.blank? ? nil : university_account.organization; end
end

