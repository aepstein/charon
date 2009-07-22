class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.references :framework, :null => false
      t.string :status, :null => false
      t.references :role, :null => false
      t.string :action, :null => false
      t.string :context, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :permissions
  end
end

