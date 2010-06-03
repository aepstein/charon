class DropPermissions < ActiveRecord::Migration
  def self.up
    drop_table :permissions
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

