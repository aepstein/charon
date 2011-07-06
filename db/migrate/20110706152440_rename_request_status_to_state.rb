class RenameRequestStatusToState < ActiveRecord::Migration
  def self.up
    remove_index :requests, [ :basis_id, :status ]
    rename_column :requests, :status, :state
    add_index :requests, [ :basis_id, :state ], :unique => true
  end

  def self.down
    raise IrreversibleMigration
  end
end

