class CreateApprovals < ActiveRecord::Migration
  def self.up
    create_table :approvals do |t|
      t.integer :user_id
      t.integer :approvable_id
      t.string :approvable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :approvals
  end
end
