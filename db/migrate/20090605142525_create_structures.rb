class CreateStructures < ActiveRecord::Migration
  def self.up
    create_table :structures do |t|
      t.string :name
      t.integer :minimum_requestors, { :null => false, :default => 1 }
      t.integer :maximum_requestors, { :null => false, :default => 1 }

      t.timestamps
    end
  end

  def self.down
    drop_table :structures
  end
end

