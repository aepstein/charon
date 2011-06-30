class RemoveRequestorsLimitsFromStructures < ActiveRecord::Migration
  def self.up
    remove_column :structures, :maximum_requestors
    remove_column :structures, :minimum_requestors
  end

  def self.down
    add_column :structures, :minimum_requestors, :integer
    add_column :structures, :maximum_requestors, :integer
  end
end
