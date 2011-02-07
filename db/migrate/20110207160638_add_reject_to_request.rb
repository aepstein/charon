class AddRejectToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :rejected_at, :datetime
    add_column :requests, :reject_message, :text
  end

  def self.down
    remove_column :requests, :reject_message
    remove_column :requests, :rejected_at
  end
end
