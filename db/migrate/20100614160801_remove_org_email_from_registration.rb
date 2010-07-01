class RemoveOrgEmailFromRegistration < ActiveRecord::Migration
  def self.up
    remove_column :registrations, :org_email
  end

  def self.down
    add_column :registrations, :org_email, :string
  end
end
