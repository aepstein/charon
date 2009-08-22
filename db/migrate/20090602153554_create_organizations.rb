class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table :organizations do |t|
      t.string :first_name, { :null => false, :default => "" }
      t.string :last_name, { :null => false }

      t.timestamps
    end
    add_index :organizations, [ :last_name, :first_name ], :unique => true
  end

  def self.down
    drop_table :organizations
  end
end

