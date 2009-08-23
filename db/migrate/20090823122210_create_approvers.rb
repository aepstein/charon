class CreateApprovers < ActiveRecord::Migration
  def self.up
    create_table :approvers do |t|
      t.references :framework, :null => false
      t.references :role, :null => false
      t.string :status, :null => false
      t.string :perspective, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :approvers
  end
end

