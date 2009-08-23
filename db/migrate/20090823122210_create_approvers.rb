class CreateApprovers < ActiveRecord::Migration
  def self.up
    create_table :approvers do |t|
      t.references :framework, :null => false
      t.references :role, :null => false
      t.string :status, :null => false
      t.string :perspective, :null => false

      t.timestamps
    end
    add_index :approvers, [:framework_id, :status, :perspective, :role_id], :unique => true
  end

  def self.down
    drop_table :approvers
  end
end

