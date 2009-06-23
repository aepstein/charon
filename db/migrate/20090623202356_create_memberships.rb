class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.integer :organization_id
      t.integer :user_id
      t.integer :registration_id
      t.integer :role_id

      t.timestamps
    end
  end

  def self.down
    drop_table :memberships
  end
end

