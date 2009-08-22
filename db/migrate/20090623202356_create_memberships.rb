class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.integer :organization_id
      t.integer :user_id
      t.integer :registration_id
      t.integer :role_id
      t.boolean :active

      t.timestamps
    end
    add_index :memberships, [ :organization_id, :user_id, :role_id ]
    add_index :memberships, [ :registration_id, :user_id, :role_id ], :unique => true
  end

  def self.down
    drop_table :memberships
  end
end

