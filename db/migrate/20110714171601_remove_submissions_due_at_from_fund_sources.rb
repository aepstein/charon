class RemoveSubmissionsDueAtFromFundSources < ActiveRecord::Migration
  def self.up
    remove_column :fund_sources, :submissions_due_at
  end

  def self.down
    add_column :fund_sources, :submissions_due_at, :datetime
  end
end
