class AccountAdjustment < ActiveRecord::Base
  belongs_to :account_transaction
  belongs_to :activity_account

  validates_presence_of :account_transaction
  validates_presence_of :activity_account
  validates_numericality_of :amount

  def credit
    return nil unless amount? && amount > 0
    amount
  end

  def debit
    return nil unless amount? && amount < 0
    amount
  end
end

