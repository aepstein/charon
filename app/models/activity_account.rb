class ActivityAccount < ActiveRecord::Base
  belongs_to :university_account, :inverse_of => :activity_accounts
  belongs_to :basis, :inverse_of => :activity_accounts
  belongs_to :category, :inverse_of => :activity_accounts

  has_many :adjustments, :dependent => :destroy, :class_name => 'AccountAdjustment',
    :inverse_of => :activity_account

  scope :organization_id_equals, lambda { |id|
    joins(:university_account).merge( UniversityAccount.unscoped.where( :organization_id => id ) )
  }
  scope :organization_id_in, lambda { |ids|
    joins(:university_account).merge( UniversityAccount.unscoped.where( :organization_id.in => ids ) )
  }

  validates_presence_of :university_account
  validates_uniqueness_of :university_account_id, :scope => [ :basis_id, :category_id ]

  def organization; university_account.blank? ? nil : university_account.organization; end
end

