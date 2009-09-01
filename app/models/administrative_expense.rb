class AdministrativeExpense < ActiveRecord::Base
  belongs_to :version

  validates_presence_of :version
  validates_numericality_of :copies, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :chalk, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :sun_ads, :greater_than_or_equal_to => 0
  validates_numericality_of :repairs_restocking, :greater_than_or_equal_to => 0
  validates_numericality_of :mailbox_wsh, :greater_than_or_equal_to => 0

  def copies_expense
    return 0.0 unless copies
    0.03 * copies
  end

  def chalk_expense
    return 0.0 unless chalk
    8.0 * chalk
  end

	def max_request
	  return 0.0 unless repairs_restocking && mailbox_wsh && chalk_expense && sun_ads
		copies_expense + chalk_expense + sun_ads + repairs_restocking + mailbox_wsh
  end

  def title
    nil
  end

end

