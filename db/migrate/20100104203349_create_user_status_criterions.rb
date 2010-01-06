class CreateUserStatusCriterions < ActiveRecord::Migration
  def self.up
    create_table :user_status_criterions do |t|
      t.integer :statuses_mask

      t.timestamps
    end
    add_index :user_status_criterions, [ :statuses_mask ],
      :unique => true, :name => 'user_status_criterions_unique'
  end

  def self.down
    remove_index :user_status_criterions, :user_status_criterions_unique
    drop_table :user_status_criterions
  end
end

