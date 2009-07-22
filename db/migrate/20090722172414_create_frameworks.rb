class CreateFrameworks < ActiveRecord::Migration
  def self.up
    create_table :frameworks do |t|
      t.string :name, :null => false
      t.boolean :must_register, { :null => false, :default => false }
      t.integer :member_percentage
      t.string :member_percentage_type

      t.timestamps
    end
  end

  def self.down
    drop_table :frameworks
  end
end

