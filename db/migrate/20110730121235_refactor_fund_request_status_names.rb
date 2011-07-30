class RefactorFundRequestStatusNames < ActiveRecord::Migration
  def self.up
    rename_column :fund_requests, :completed_notice_at, :tentative_notice_at
    rename_column :fund_requests, :submitted_notice_at, :finalized_notice_at
    rename_column :fund_requests, :accepted_notice_at, :submitted_notice_at
  end

  def self.down
    rename_column :fund_requests, :submitted_notice_at, :accepted_notice_at
    rename_column :fund_requests, :finalized_notice_at, :submitted_notice_at
    rename_column :fund_requests, :tentative_notice_at, :completed_notice_at
  end
end
