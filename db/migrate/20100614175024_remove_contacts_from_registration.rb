class RemoveContactsFromRegistration < ActiveRecord::Migration
  def self.up
    remove_column :registrations, :pre_first_name
    remove_column :registrations, :pre_last_name
    remove_column :registrations, :pre_email
    remove_column :registrations, :pre_net_id
    remove_column :registrations, :vpre_first_name
    remove_column :registrations, :vpre_last_name
    remove_column :registrations, :vpre_email
    remove_column :registrations, :vpre_net_id
    remove_column :registrations, :tre_first_name
    remove_column :registrations, :tre_last_name
    remove_column :registrations, :tre_email
    remove_column :registrations, :tre_net_id
    remove_column :registrations, :officer_first_name
    remove_column :registrations, :officer_last_name
    remove_column :registrations, :officer_email
    remove_column :registrations, :officer_net_id
    remove_column :registrations, :adv_first_name
    remove_column :registrations, :adv_last_name
    remove_column :registrations, :adv_email
    remove_column :registrations, :adv_net_id
  end

  def self.down
    add_column :registrations, :adv_net_id, :string
    add_column :registrations, :adv_email, :string
    add_column :registrations, :adv_last_name, :string
    add_column :registrations, :adv_first_name, :string
    add_column :registrations, :officer_net_id, :string
    add_column :registrations, :officer_email, :string
    add_column :registrations, :officer_last_name, :string
    add_column :registrations, :officer_first_name, :string
    add_column :registrations, :tre_net_id, :string
    add_column :registrations, :tre_email, :string
    add_column :registrations, :tre_last_name, :string
    add_column :registrations, :tre_first_name, :string
    add_column :registrations, :vpre_net_id, :string
    add_column :registrations, :vpre_email, :string
    add_column :registrations, :vpre_last_name, :string
    add_column :registrations, :vpre_first_name, :string
    add_column :registrations, :pre_net_id, :string
    add_column :registrations, :pre_email, :string
    add_column :registrations, :pre_last_name, :string
    add_column :registrations, :pre_first_name, :string
  end
end
