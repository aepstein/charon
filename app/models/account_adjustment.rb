class AccountAdjustment < ActiveRecord::Base
  attr_accessible :activity_account_id, :amount

  belongs_to :account_transaction, :inverse_of => :adjustments
  belongs_to :activity_account, :inverse_of => :adjustments

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

