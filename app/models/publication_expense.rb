class PublicationExpense < ActiveRecord::Base
  belongs_to :version
	before_validation :calculate_copies

  validates_presence_of :version
  validates_numericality_of :no_of_issues, :only_integer => true, :greater_than => 0
  validates_numericality_of :no_of_copies_per_issue, :only_integer => true, :greater_than => 0
  validates_numericality_of :total_copies, :only_integer => true
  validates_numericality_of :purchase_price, :greater_than_or_equal_to => 0
  validates_numericality_of :revenue, :greater_than_or_equal_to => 0
  validates_numericality_of :cost_publication, :greater_than_or_equal_to => 0
  validates_numericality_of :total_cost_publication, :greater_than_or_equal_to => 0

	def calculate_copies
	  return unless no_of_issues && no_of_copies_per_issue && purchase_price && cost_publication
		self.total_copies = no_of_issues * no_of_copies_per_issue
		self.revenue = purchase_price * total_copies
		self.total_cost_publication = no_of_issues * cost_publication
	end

	def max_request
	  total_cost_publication
  end

end

