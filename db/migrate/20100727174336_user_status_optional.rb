class UserStatusOptional < ActiveRecord::Migration
  def self.up
    change_column :users, :status, :string, :null => true, :default => nil
    say_with_time 'Setting "unknown" users to NULL status...' do
      rows = connection.update_sql "UPDATE users SET status = NULL WHERE status = 'unknown'"
      say "#{rows} records affected", true
    end
    say_with_time 'Shifting user_status_criterions to reflect elimination of "unknown" option' do
      rows = connection.update_sql "UPDATE user_status_criterions SET statuses_mask = (statuses_mask/2)"
      say "#{rows} records affected", true
    end
  end

  def self.down
    change_column :users, :status, :string, :null => false, :default => 'unknown'
    say_with_time 'Shifting user_status_criterions to reflect addition of "unknown" option' do
      rows = connection.update_sql "UPDATE user_status_criterions SET statuses_mask = (statuses_mask*2)"
      say "#{rows} records affected", true
    end
  end
end

