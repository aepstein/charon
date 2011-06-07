class AddCompletedNoticeAtToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :completed_notice_at, :datetime
    execute "UPDATE requests SET completed_notice_at = created_at"
  end

  def self.down
    remove_column :requests, :completed_notice_at
  end
end

