class CreateRegisteredMembershipConditions < ActiveRecord::Migration
  def self.up
    create_table :registered_membership_conditions do |t|
      t.string :membership_type
      t.float :membership_percentage

      t.timestamps
    end
  end

  def self.down
    drop_table :registered_membership_conditions
  end
end
