class DropOrganizationsRequests < ActiveRecord::Migration
  def self.up
    drop_table :organizations_requests
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

