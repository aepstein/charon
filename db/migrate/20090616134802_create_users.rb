class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.timestamps
      t.string :net_id, :null => false
      t.string :crypted_password, :null => false
      t.string :password_salt, :null => false
      t.string :persistence_token, :null => false
      t.string :email, :null => false
      t.string :status, { :null => false, :default => 'unknown' }
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.date :date_of_birth
      t.boolean :admin, { :null => false, :default => false }
    end

    add_index :users, [ :net_id ], :unique => true
    add_index :users, :persistence_token

  end

  def self.down
    drop_table :users
  end
end

