class RemovePermissionsMaskFromRole < ActiveRecord::Migration
  def self.up
    remove_column :roles, :permissions_mask
  end

  def self.down
    add_column :roles, :permissions_mask, :integer
  end
end
