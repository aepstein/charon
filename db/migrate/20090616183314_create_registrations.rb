class CreateRegistrations < ActiveRecord::Migration
  def self.up
    create_table :registrations do |t|
      t.integer :id, { :null => false }
      t.integer :parent_id
      t.integer :organization_id
      t.string :name
      t.string :purpose
      t.boolean :independent
      t.boolean :registered, { :null => false, :default => false }
      t.string :funding_sources
      t.integer :number_of_undergrads, { :null => false, :default => 0 }
      t.integer :number_of_grads, { :null => false, :default => 0 }
      t.integer :number_of_staff, { :null => false, :default => 0 }
      t.integer :number_of_faculty, { :null => false, :default => 0 }
      t.integer :number_of_alumni, { :null => false, :default => 0 }
      t.integer :number_of_others, { :null => false, :default => 0 }
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
  end

  def self.down
    drop_table :registrations
  end
end

