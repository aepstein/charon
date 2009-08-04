class CreateApprovals < ActiveRecord::Migration
  def self.up
    create_table :approvals do |t|
      t.integer :user_id, :null => false
      t.integer :approvable_id, :null => false
      t.string :approvable_type, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :approvals
  end
end

