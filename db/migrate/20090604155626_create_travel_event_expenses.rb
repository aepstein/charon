class CreateTravelEventExpenses < ActiveRecord::Migration
  def self.up
    create_table :travel_event_expenses do |t|
      t.date :event_date, :null => false
      t.string :event_title, :null => false
      t.string :event_location, :null => false
      t.string :event_purpose, :null => false
      t.integer :members_per_group, :null => false
      t.integer :number_of_groups, { :null => false, :default => 1 }
      t.decimal :mileage, { :null => false, :default => 0 }
      t.integer :nights_of_lodging, { :null => false, :default => 0 }
      t.decimal :per_person_fees, { :null => false, :default => 0 }
      t.decimal :per_group_fees, { :null => false, :default => 0 }
      t.decimal :total_eligible_expenses, { :null => false, :default => 0 }
      t.integer :version_id, :null => false

      t.timestamps
    end
    add_index :travel_event_expenses, :version_id
  end

  def self.down
    drop_table :travel_event_expenses
  end
end

