class AddSubmittedNoticeAtToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :submitted_notice_at, :datetime
    execute <<-SQL
      UPDATE requests SET submitted_notice_at = approval_checkpoint
      WHERE status = 'submitted'
    SQL
    execute <<-SQL
      UPDATE requests SET submitted_notice_at = #{connection.quote Time.zone.now}
      WHERE status = 'submitted' AND submitted_notice_at IS NULL
    SQL
  end

  def self.down
    remove_column :requests, :submitted_notice_at
  end
end

