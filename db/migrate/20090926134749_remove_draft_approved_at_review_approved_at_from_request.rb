class RemoveDraftApprovedAtReviewApprovedAtFromRequest < ActiveRecord::Migration
  def self.up
    remove_column :requests, :draft_approved_at
    remove_column :requests, :review_approved_at
  end

  def self.down
    add_column :requests, :review_approved_at, :datetime
    add_column :requests, :draft_approved_at, :datetime
  end
end
