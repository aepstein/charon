class RenameApproverStatusToState < ActiveRecord::Migration
  def self.up
    remove_index :approvers, :name => 'approvers_unique_constraint'
    rename_column :approvers, :status, :state
    add_index :approvers, [ :framework_id, :state, :perspective, :role_id ],
      :name => 'approvers_unique_constraint', :unique => true
  end

  def self.down
    remove_index :approvers, :name => 'approvers_unique_constraint'
    rename_column :approvers, :state, :status
    add_index :approvers, [ :framework_id, :status, :perspective, :role_id ],
      :name => 'approvers_unique_constraint', :unique => true
  end
end

