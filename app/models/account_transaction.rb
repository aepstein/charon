class AccountTransaction < ActiveRecord::Base
  has_many :account_adjustments, :dependent => :destroy

  validates_presence_of :status
  validates_date :effective_on

  include AASM
  aasm_column :status
  aasm_initial_state :tentative
  aasm_state :tentative
  aasm_state :approved

  aasm_event :approve do
    transitions :to => :approved, :from => :tentative
  end
end

