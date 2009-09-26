class AddReleaseMessageToBasis < ActiveRecord::Migration
  def self.up
    add_column :bases, :release_message, :text
  end

  def self.down
    remove_column :bases, :release_message
  end
end
