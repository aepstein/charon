class PublicationExpense < ActiveRecord::Base
  attr_accessible :title, :number_of_issues, :copies_per_issue, :price_per_copy,
    :cost_per_issue
  attr_readonly :edition_id

  belongs_to :edition, :inverse_of => :publication_expense

  validates :edition, :presence => true
  validates :title, :presence => true
  validates_numericality_of :number_of_issues, :only_integer => true, :greater_than => 0
  validates_numericality_of :copies_per_issue, :only_integer => true, :greater_than => 0
  validates_numericality_of :price_per_copy, :greater_than_or_equal_to => 0
  validates_numericality_of :cost_per_issue, :greater_than_or_equal_to => 0

  def total_copies
    return 0 unless number_of_issues && copies_per_issue
    number_of_issues * copies_per_issue
  end

  def revenue
    return 0.0 unless price_per_copy
    price_per_copy * total_copies
  end

	def max_request
	  return 0.0 unless number_of_issues && cost_per_issue
	  number_of_issues * cost_per_issue
  end

end

