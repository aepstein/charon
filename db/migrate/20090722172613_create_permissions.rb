class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.references :framework, :null => false
      t.string :status, :null => false
      t.references :role, :null => false
      t.string :action, :null => false
      t.string :perspective, :null => false

      t.timestamps
    end
    add_index :permissions, [ :framework_id, :role_id, :status, :perspective, :action ], :unique => true, :name => 'permissions_unique_constraint'
  end

  def self.down
    drop_table :permissions
  end
end

