class RemoveStateFromApprovers < ActiveRecord::Migration
  def self.up
    remove_index :approvers, :name => :approvers_unique_constraint
    remove_column :approvers, :state

    say 'Attempting to implement unique index -- manual intervention may be necessary.'
    add_index :approvers, [ :framework_id, :perspective, :role_id ],
      :name => :approvers_unique_constraint, :unique => true
  end

  def self.down
    raise IrreversibleMigration
  end
end

