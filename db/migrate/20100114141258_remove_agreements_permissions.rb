class RemoveAgreementsPermissions < ActiveRecord::Migration
  def self.up
    say_with_time "Creating requirements for each agreement corresponding to associated permission" do
      connection.insert "INSERT INTO requirements (fulfillable_type, created_at, permission_id, fulfillable_id) " +
        "SELECT DISTINCT 'Agreement', #{connection.quote DateTime.now.utc}, agreements_permissions.permission_id, agreement_id " +
        "FROM agreements_permissions LEFT JOIN requirements ON " +
        "agreements_permissions.agreement_id = requirements.fulfillable_id AND " +
        "agreements_permissions.permission_id = requirements.permission_id AND " +
        "requirements.fulfillable_type = 'Agreement' " +
        "WHERE requirements.id IS NULL"
    end
    drop_table :agreements_permissions
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
    create_table :agreements_permissions
  end
end

