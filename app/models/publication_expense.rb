class PublicationExpense < ActiveRecord::Base
  has_one :version, :as => :requestable
  before_save :calculate_copies

	def calculate_copies
		self.total_copies = no_of_issues * no_of_copies_per_issue
		self.revenue = purchase_price * total_copies
		self.total_cost_publication = no_of_issues * cost_publication
	end
end

