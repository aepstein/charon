class AccountAdjustment < ActiveRecord::Base
  attr_accessible :activity_account_id, :amount

  belongs_to :account_transaction, inverse_of: :adjustments
  belongs_to :activity_account, inverse_of: :adjustments

  validates :account_transaction, presence: true
  validates :activity_account, presence: true
  validates :amount, numericality: true

  def credit
    return nil unless amount? && amount > 0.0
    amount
  end

  def debit
    return nil unless amount? && amount < 0.0
    amount
  end
end

