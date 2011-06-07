class AddReleasedNoticeAtToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :released_notice_at, :datetime
    execute "UPDATE requests SET released_notice_at = released_at"
    execute <<-SQL
      UPDATE requests SET released_notice_at = #{connection.quote Time.zone.now}
      WHERE status = 'released' AND released_notice_at IS NULL
    SQL
  end

  def self.down
    remove_column :requests, :released_notice_at
  end
end

