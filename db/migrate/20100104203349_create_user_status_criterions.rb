class CreateUserStatusCriterions < ActiveRecord::Migration
  def self.up
    create_table :user_status_criterions do |t|
      t.integer :statuses_mask

      t.timestamps
    end
  end

  def self.down
    drop_table :user_status_criterions
  end
end
