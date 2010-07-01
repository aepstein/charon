class AdministrativeExpense < ActiveRecord::Base
  MAILBOX_OPTIONS = {
    "$0 - no mailbox" => "0",
    "$#{APP_CONFIG['expenses']['general']['mailbox']['existing']} - existing" => APP_CONFIG['expenses']['general']['mailbox']['existing'],
    "$#{APP_CONFIG['expenses']['general']['mailbox']['new']} - new" => APP_CONFIG['expenses']['general']['mailbox']['new']
  }

  belongs_to :edition

  validates_presence_of :edition
  validates_numericality_of :copies, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :chalk, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :sun_ads, :greater_than_or_equal_to => 0
  validates_numericality_of :repairs_restocking, :greater_than_or_equal_to => 0
  validates_numericality_of :mailbox_wsh, :greater_than_or_equal_to => 0

  def copies_expense
    return 0.0 unless copies
    APP_CONFIG['expenses']['general']['copies'] * copies
  end

  def chalk_expense
    return 0.0 unless chalk
    APP_CONFIG['expenses']['general']['chalk'] * chalk
  end

	def max_request
	  return 0.0 unless repairs_restocking && mailbox_wsh && chalk_expense && sun_ads
		copies_expense + chalk_expense + sun_ads + repairs_restocking + mailbox_wsh
  end

  def title
    nil
  end

end

