class AddExternalIdToRegistration < ActiveRecord::Migration
  def self.up
    add_column :registrations, :external_id, :integer
    add_index :registrations, :external_id, :unique => true
    Registration.update_all 'external_id = id'
  end

  def self.down
    remove_column :registrations, :external_id
  end
end

