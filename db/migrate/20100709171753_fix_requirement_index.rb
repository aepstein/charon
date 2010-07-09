class FixRequirementIndex < ActiveRecord::Migration
  def self.up
    remove_index :requirements, :name => :requirements_unique
    add_index :requirements, [ :fulfillable_id, :fulfillable_type, :role_id ],
      :unique => true, :name => 'requirements_unique'
  end

  def self.down
    remove_index :requirements, :name => :requirements_unique
    add_index :requirements, [ :fulfillable_id, :fulfillable_type ],
      :unique => true, :name => 'requirements_unique'
  end
end

