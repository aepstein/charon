class CreateRegistrations < ActiveRecord::Migration
  def self.up
    create_table :registrations, :id => false do |t|
      t.integer :id, { :key => true, :null => false }
      t.integer :parent_id
      t.integer :organization_id
      t.string :name
      t.string :purpose
      t.boolean :is_independent
      t.boolean :is_registered
      t.string :funding_sources
      t.integer :number_of_undergrads
      t.integer :number_of_grads
      t.integer :number_of_staff
      t.integer :number_of_faculty
      t.integer :number_of_alumni
      t.integer :number_of_others
      t.string :org_email
      t.datetime :when_updated
      t.string :adv_first_name
      t.string :adv_last_name
      t.string :adv_email
      t.string :adv_net_id
      t.string :adv_address
      t.string :pre_first_name
      t.string :pre_last_name
      t.string :pre_email
      t.string :pre_net_id
      t.string :tre_first_name
      t.string :tre_last_name
      t.string :tre_email
      t.string :tre_net_id
      t.string :vpre_first_name
      t.string :vpre_last_name
      t.string :vpre_email
      t.string :vpre_net_id
      t.string :officer_first_name
      t.string :officer_last_name
      t.string :officer_email
      t.string :officer_net_id
      t.timestamps
    end
    add_index :registrations, :org_id, :unique => true
  end

  def self.down
    drop_table :registrations
  end
end

