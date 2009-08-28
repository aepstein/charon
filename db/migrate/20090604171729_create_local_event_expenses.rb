class CreateLocalEventExpenses < ActiveRecord::Migration
  def self.up
    create_table :local_event_expenses do |t|
      t.date :date, :null => false
      t.string :title, :null => false
      t.string :location, :null => false
      t.string :purpose, :null => false
      t.integer :number_of_attendees, { :null => false, :default => 0 }
      t.decimal :price_per_attendee, { :null => false, :default => 0 }
      t.integer :copies_quantity, { :null => false, :default => 0 }
      t.decimal :services_cost, { :null => false, :default => 0 }
      t.integer :version_id, :null => false

      t.timestamps
    end
    add_index :local_event_expenses, :version_id
  end

  def self.down
    drop_table :local_event_expenses
  end
end

