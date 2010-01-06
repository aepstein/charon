class CreateRequirements < ActiveRecord::Migration
  def self.up
    create_table :requirements do |t|
      t.references :permission, :null => false
      t.references :fulfillable, :null => false, :polymorphic => true

      t.timestamp :created_at, :null => false
    end
    add_index :requirements, [ :permission_id, :fulfillable_id, :fulfillable_type ],
      :unique => true, :name => 'requirements_unique'
  end

  def self.down
    remove_index :requirments, :requirements_unique
    drop_table :requirements
  end
end

