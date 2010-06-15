class AddExternalTermIdToRegistration < ActiveRecord::Migration
  def self.up
    add_column :registrations, :external_term_id, :integer
    remove_index :registrations, :external_id
    add_index :registrations, [ :external_id, :external_term_id ], :unique => true
  end

  def self.down
    remove_index :registrations, [ :external_id, :external_term_id ]
    add_index :registrations, :external_id, :unique => true
    remove_column :registrations, :external_term_id
  end
end

