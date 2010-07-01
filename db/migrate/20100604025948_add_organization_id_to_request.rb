class AddOrganizationIdToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :organization_id, :integer
    say_with_time "Associating requests with single organizations..." do
      rows = connection.update_sql "UPDATE requests SET organization_id = " +
        "(SELECT organizations_requests.organization_id FROM organizations_requests WHERE " +
        "request_id = requests.id LIMIT 1)"
      say "#{rows} rows affected.", true
    end
    change_column :requests, :organization_id, :integer, :null => false
  end

  def self.down
    remove_column :requests, :organization_id
  end
end

