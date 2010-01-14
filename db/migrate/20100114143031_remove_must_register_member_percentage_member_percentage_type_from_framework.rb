class RemoveMustRegisterMemberPercentageMemberPercentageTypeFromFramework < ActiveRecord::Migration
  def self.up
    say_with_time "Creating registration criterions for frameworks if they don't exist" do
      connection.insert "INSERT INTO registration_criterions (must_register, minimal_percentage, type_of_member, created_at, updated_at) " +
        "SELECT DISTINCT frameworks.must_register, frameworks.member_percentage, " +
        "frameworks.member_percentage_type, #{connection.quote DateTime.now.utc}, " +
        "#{connection.quote DateTime.now.utc} FROM frameworks LEFT JOIN registration_criterions " +
        "ON frameworks.must_register = registration_criterions.must_register AND " +
        "frameworks.member_percentage = registration_criterions.minimal_percentage AND " +
        "frameworks.member_percentage_type = registration_criterions.type_of_member " +
        "WHERE registration_criterions.id IS NULL"
    end
    say_with_time "Adding framework registration criterions to existing create and approve permissions" do
      connection.insert "INSERT INTO requirements (fulfillable_type, created_at, permission_id, fulfillable_id) " +
        "SELECT 'RegistrationCriterion', #{connection.quote DateTime.now.utc}, permissions.id, registration_criterions.id FROM " +
        "permissions INNER JOIN frameworks INNER JOIN registration_criterions ON " +
        "permissions.framework_id = frameworks.id AND frameworks.must_register = registration_criterions.must_register AND " +
        "frameworks.member_percentage = registration_criterions.minimal_percentage AND " +
        "frameworks.member_percentage_type = registration_criterions.type_of_member " +
        "WHERE action IN ('create','approve')"
    end
    remove_column :frameworks, :must_register
    remove_column :frameworks, :member_percentage
    remove_column :frameworks, :member_percentage_type
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
    add_column :frameworks, :member_percentage_type, :string
    add_column :frameworks, :member_percentage, :integer
    add_column :frameworks, :must_register, :boolean
  end
end

