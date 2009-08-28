class CreateTravelEventExpenses < ActiveRecord::Migration
  def self.up
    create_table :travel_event_expenses do |t|
      t.date :date, :null => false
      t.string :title, :null => false
      t.string :location, :null => false
      t.string :purpose, :null => false
      t.integer :travelers_per_group, :null => false
      t.integer :number_of_groups, { :null => false, :default => 1 }
      t.integer :distance, { :null => false, :default => 0 }
      t.integer :nights_of_lodging, { :null => false, :default => 0 }
      t.decimal :per_person_fees, { :null => false, :default => 0 }
      t.decimal :per_group_fees, { :null => false, :default => 0 }
      t.integer :version_id, :null => false

      t.timestamps
    end
    add_index :travel_event_expenses, :version_id, :unique => true
  end

  def self.down
    drop_table :travel_event_expenses
  end
end

