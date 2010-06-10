class AddPerspectivesToRequirement < ActiveRecord::Migration
  def self.up
    add_column :requirements, :perspectives_mask, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :requirements, :perspectives_mask
  end
end

