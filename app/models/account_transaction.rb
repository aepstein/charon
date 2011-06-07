class AccountTransaction < ActiveRecord::Base
  has_many :adjustments, :dependent => :destroy, :inverse_of => :account_transaction,
    :class_name => 'AccountAdjustment' do
    def balance
      return 0.0 if length == 0
      map( &:amount ).reduce( :+ )
    end
    def balanced?
      balance == 0.0
    end
    def for_activity_account( activity_account )
      select { |adjustment| adjustment.activity_account_id == activity_account.id }.first
    end
  end
  has_many :activity_accounts, :through => :adjustments do
    def allowed
      ActivityAccount.organization_id_in( proxy_owner.organization_ids )
    end
  end

  accepts_nested_attributes_for :adjustments

  validates_presence_of :status
  validates_date :effective_on
  validate do |r|
    r.errors.add :base, "adjustments must balance" unless r.adjustments.balanced?
  end

  state_machine :status, :initial => :tentative do
    state :tentative, :approved

    event :approve do
      transition :tentative => :approved
    end
  end

  def organizations
    Organization.joins( :bases, :university_accounts ).merge(
      UniversityAccount.unscoped.joins( :activity_accounts ).merge(
        ActivityAccount.unscoped.where( :id.in => adjustments.map( &:activity_account_id ) )
      )
    ).or.merge(
      Basis.unscoped.joins( :activity_accounts ).where( :id.in => adjustments.map( &:activity_account_id ) )
    )
  end

end

