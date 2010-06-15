class RemoveParentIdFromRegistration < ActiveRecord::Migration
  def self.up
    remove_index :registrations, :parent_id
    remove_column :registrations, :parent_id
  end

  def self.down
    add_column :registrations, :parent_id, :integer
    add_index :registrations, :parent_id
  end
end

