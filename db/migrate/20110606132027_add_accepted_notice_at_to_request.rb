class AddAcceptedNoticeAtToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :accepted_notice_at, :datetime
    execute "UPDATE requests SET accepted_notice_at = accepted_at"
    execute <<-SQL
      UPDATE requests SET accepted_notice_at = #{connection.quote Time.zone.now}
      WHERE status = 'accepted' AND accepted_notice_at IS NULL
    SQL
  end

  def self.down
    remove_column :requests, :accepted_notice_at
  end
end

