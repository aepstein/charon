class RenameFundRequestsAcceptedAtToSubmittedAt < ActiveRecord::Migration
  def self.up
    rename_column :fund_requests, :accepted_at, :submitted_at
  end

  def self.down
    rename_column :fund_requests, :submitted_at, :accepted_at
  end
end

