class AdministrativeExpense < ActiveRecord::Base
  belongs_to :version

  validates_presence_of :version
  validates_numericality_of :copies, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :repairs_restocking, :greater_than_or_equal_to => 0
  validates_numericality_of :mailbox_wsh, :greater_than_or_equal_to => 0

  def copies_expense
    return 0.0 unless copies
    0.03 * copies
  end

	def total
	  return 0.0 unless repairs_restocking && mailbox_wsh
		copies_expense + repairs_restocking + mailbox_wsh
	end

	def max_request
	  total
  end

end

