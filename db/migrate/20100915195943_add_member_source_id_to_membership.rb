class AddMemberSourceIdToMembership < ActiveRecord::Migration
  def self.up
    add_column :memberships, :member_source_id, :integer
    add_index :memberships, :member_source_id
  end

  def self.down
    drop_index :memberships, :member_source_id
    remove_column :memberships, :member_source_id
  end
end

