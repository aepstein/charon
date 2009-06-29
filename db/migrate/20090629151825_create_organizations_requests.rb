class CreateOrganizationsRequests < ActiveRecord::Migration
  def self.up
    create_table :organizations_requests, :id => false do |t|
      t.integer :organization_id, :null => false
      t.integer :request_id, :null => false
    end
    add_index :organizations_requests,
              [ :organization_id, :request_id ],
              :unique => true
  end

  def self.down
    drop_table :organizations_requests
  end
end

