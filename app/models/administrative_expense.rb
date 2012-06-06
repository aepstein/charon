class AdministrativeExpense < ActiveRecord::Base
  MAILBOX_OPTIONS = {
    "$0 - no mailbox" => "0",
    "$#{Charon::Application.app_config['expenses']['general']['mailbox']['existing']} - existing" => Charon::Application.app_config['expenses']['general']['mailbox']['existing'],
    "$#{Charon::Application.app_config['expenses']['general']['mailbox']['new']} - new" => Charon::Application.app_config['expenses']['general']['mailbox']['new']
  }

  attr_accessible :copies, :repairs_restocking, :mailbox_wsh, :chalk, :sun_ads
  attr_readonly :fund_edition_id

  belongs_to :fund_edition, inverse_of: :administrative_expense

  has_paper_trail class_name: 'SecureVersion'

  validates :fund_edition, presence: true
  validates :copies, numericality: { only_integer: true,
    greater_than_or_equal_to: 0 }
  validates :chalk, numericality: { only_integer: true,
    greater_than_or_equal_to: 0 }
  validates :sun_ads, numericality: { greater_than_or_equal_to: 0 }
  validates :repairs_restocking,
    numericality: { greater_than_or_equal_to: 0 }
  validates :mailbox_wsh,
    numericality: { greater_than_or_equal_to: 0 }

  def copies_expense
    return 0.0 unless copies
    Charon::Application.app_config['expenses']['general']['copies'] * copies
  end

  def chalk_expense
    return 0.0 unless chalk
    Charon::Application.app_config['expenses']['general']['chalk'] * chalk
  end

	def max_fund_request
	  return 0.0 unless repairs_restocking && mailbox_wsh && chalk_expense && sun_ads
		copies_expense + chalk_expense + sun_ads + repairs_restocking + mailbox_wsh
  end

  def title
    nil
  end

end

