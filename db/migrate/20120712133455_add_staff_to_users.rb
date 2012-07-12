class AddStaffToUsers < ActiveRecord::Migration
  def change
    add_column :users, :staff, :boolean, null: false, default: false
  end
end

