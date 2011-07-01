class AddWithdrawnByUserIdToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :withdrawn_by_user_id, :integer
    add_column :requests, :withdrawn_notice_at, :datetime
    add_column :requests, :withdrawn_at, :datetime
    add_index :requests, :withdrawn_notice_at
  end

  def self.down
    remove_index :requests, :withdrawn_notice_at
    remove_column :requests, :withdrawn_at
    remove_column :requests, :withdrawn_notice_at
    remove_column :requests, :withdrawn_by_user_id
  end
end

