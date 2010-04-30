class AddSubmissionsDueAtToBasis < ActiveRecord::Migration
  def self.up
    add_column :bases, :submissions_due_at, :datetime
  end

  def self.down
    remove_column :bases, :submissions_due_at
  end
end
