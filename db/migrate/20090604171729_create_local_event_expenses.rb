class CreateLocalEventExpenses < ActiveRecord::Migration
  def self.up
    create_table :local_event_expenses do |t|
      t.date :date_of_event, :null => false
      t.string :title_of_event, :null => false
      t.string :location_of_event, :null => false
      t.string :purpose_of_event, :null => false
      t.integer :anticipated_no_of_attendees, { :null => false, :default => 0 }
      t.decimal :admission_charge_per_attendee, { :null => false, :default => 0 }
      t.integer :number_of_publicity_copies, { :null => false, :default => 0 }
      t.decimal :rental_equipment_services, { :null => false, :default => 0 }
      t.decimal :total_copy_rate, { :null => false, :default => 0 }
      t.decimal :copyright_fees, { :null => false, :default => 0 }
      t.decimal :total_eligible_expenses, { :null => false, :default => 0 }
      t.decimal :admission_charge_revenue, { :null => false, :default => 0 }
      t.decimal :total_request_amount, { :null => false, :default => 0 }
      t.integer :version_id, :null => false

      t.timestamps
    end
    add_index :local_event_expenses, :version_id
  end

  def self.down
    drop_table :local_event_expenses
  end
end

