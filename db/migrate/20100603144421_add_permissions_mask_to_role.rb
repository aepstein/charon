class AddPermissionsMaskToRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :permissions_mask, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :roles, :permissions_mask
  end
end

