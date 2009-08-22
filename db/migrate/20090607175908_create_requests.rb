class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.integer :basis_id, :null => false
      t.string :status, { :null => false, :default => 'started' }
      t.datetime :draft_approved_at
      t.datetime :accepted_at
      t.datetime :review_approved_at
      t.datetime :released_at

      t.timestamps
    end
    add_index :requests, [:basis_id, :status]
  end

  def self.down
    drop_table :requests
  end
end

