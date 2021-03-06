class AccountTransaction < ActiveRecord::Base
  attr_accessible :effective_on, :adjustments_attributes

  has_many :adjustments, dependent: :destroy, inverse_of: :account_transaction,
    class_name: 'AccountAdjustment' do
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
  has_many :activity_accounts, through: :adjustments do
    def allowed
      ActivityAccount.organization_id_in( proxy_association.owner.organization_ids )
    end
  end
  has_one :fund_grant, through: :activity_accounts
  has_one :organization, through: :fund_grants

  accepts_nested_attributes_for :adjustments

  validates :status, presence: true
  validates :effective_on, timeliness: { type: :date }
#  validate do |r|
#    r.errors.add :base, "adjustments must balance" unless r.adjustments.balanced?
#  end

  state_machine :status, initial: :tentative do
    state :tentative, :approved

    event :approve do
      transition :tentative => :approved
    end
  end

end

