class PublicationExpense < ActiveRecord::Base
  attr_accessible :title, :number_of_issues, :copies_per_issue, :price_per_copy,
    :cost_per_issue
  attr_readonly :fund_edition_id

  belongs_to :fund_edition, inverse_of: :publication_expense

  has_paper_trail class_name: 'SecureVersion'

  validates :fund_edition, presence: true
  validates :title, presence: true
  validates :number_of_issues,
    numericality: { only_integer: true, greater_than: 0 }
  validates :copies_per_issue,
    numericality: { only_integer: true, greater_than: 0 }
  validates :price_per_copy,
    numericality: { greater_than_or_equal_to: 0 }
  validates :cost_per_issue,
    numericality: { greater_than_or_equal_to: 0 }

  def total_copies
    return 0 unless number_of_issues && copies_per_issue
    number_of_issues * copies_per_issue
  end

  def revenue
    return 0.0 unless price_per_copy
    price_per_copy * total_copies
  end

	def max_fund_request
	  return 0.0 unless number_of_issues && cost_per_issue
	  number_of_issues * cost_per_issue
  end

end

