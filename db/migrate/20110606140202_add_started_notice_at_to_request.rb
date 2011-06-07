class AddStartedNoticeAtToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :started_notice_at, :datetime
    execute "UPDATE requests SET started_notice_at = created_at"
  end

  def self.down
    remove_column :requests, :started_notice_at
  end
end

