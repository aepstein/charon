class CreateMembershipCriterions < ActiveRecord::Migration
  def self.up
    create_table :membership_criterions do |t|
      t.integer :minimal_percentage
      t.string :type_of_member

      t.timestamps
    end
  end

  def self.down
    drop_table :membership_criterions
  end
end
