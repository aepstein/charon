class RemovePermissionFromRequirement < ActiveRecord::Migration
  def self.up
    remove_column :requirements, :permission_id
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

