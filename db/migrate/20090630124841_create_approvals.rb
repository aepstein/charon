class CreateApprovals < ActiveRecord::Migration
  def self.up
    create_table :approvals do |t|
      t.integer :user_id, :null => false
      t.integer :approvable_id, :null => false
      t.string :approvable_type, :null => false

      t.datetime :created_at
    end
    add_index :approvals, [ :approvable_id, :approvable_type, :user_id ], :unique => true
  end

  def self.down
    drop_table :approvals
  end
end

