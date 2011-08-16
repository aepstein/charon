class AddLastCurrentRegistrationIdToOrganizations < ActiveRecord::Migration
  class Organization < ActiveRecord::Base
  end

  def up
    add_column :organizations, :last_current_registration_id, :integer
    say_with_time 'Populating last_current_registration_id for currently registered organizations' do
      Organization.update_all "last_current_registration_id = ( " +
      "SELECT registrations.id FROM registrations INNER JOIN registration_terms " +
      "ON registrations.registration_term_id = registration_terms.id " +
      "WHERE organization_id = organizations.id AND " +
      "registration_terms.current = #{connection.quote true} " +
      "LIMIT 1 )"
    end
    say_with_time 'Populating previously registered organizations with most recent' do
      Organization.update_all "last_current_registration_id = ( " +
      "SELECT registrations.id FROM registrations INNER JOIN registration_terms " +
      "ON registrations.registration_term_id = registration_terms.id " +
      "WHERE organization_id = organizations.id " +
      "ORDER BY registration_terms.id DESC " +
      "LIMIT 1 )",
      :last_current_registration_id => nil
    end
  end

  def down
    remove_column :organizations, :last_current_registration_id
  end
end

