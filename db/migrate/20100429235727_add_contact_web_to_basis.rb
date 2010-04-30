class AddContactWebToBasis < ActiveRecord::Migration
  def self.up
    add_column :bases, :contact_web, :string
  end

  def self.down
    remove_column :bases, :contact_web
  end
end
