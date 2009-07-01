class PublicationExpense < ActiveRecord::Base
  has_one :version, :as => :requestable
  before_save :calculate_copies

	def calculate_copies
		self.total_copies = no_of_issues.to_i * no_of_copies_per_issue.to_i
		self.revenue = purchase_price.to_f * total_copies
		self.total_cost_publication = no_of_issues.to_i * cost_publication.to_f
	end
end

