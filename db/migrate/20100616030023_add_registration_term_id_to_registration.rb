class AddRegistrationTermIdToRegistration < ActiveRecord::Migration
  def self.up
    add_column :registrations, :registration_term_id, :integer
  end

  def self.down
    remove_column :registrations, :registration_term_id
  end
end
