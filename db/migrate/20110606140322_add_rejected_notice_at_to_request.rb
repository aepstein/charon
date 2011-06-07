class AddRejectedNoticeAtToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :rejected_notice_at, :datetime
    execute "UPDATE requests SET rejected_notice_at = rejected_at"
    execute <<-SQL
      UPDATE requests SET rejected_notice_at = #{connection.quote Time.zone.now}
      WHERE status = 'rejected' AND rejected_notice_at IS NULL
    SQL
  end

  def self.down
    remove_column :requests, :rejected_notice_at
  end
end

