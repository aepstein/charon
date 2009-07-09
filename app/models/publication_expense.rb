class PublicationExpense < ActiveRecord::Base
  belongs_to :version
	before_validation :calculate_copies

	def calculate_copies
		self.total_copies = no_of_issues * no_of_copies_per_issue
		self.revenue = purchase_price * total_copies
		self.total_cost_publication = no_of_issues * cost_publication
	end

	def max_request
	  total_cost_publication
  end

end

