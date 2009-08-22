class CreateLocalEventExpenses < ActiveRecord::Migration
  def self.up
    create_table :local_event_expenses do |t|
      t.date :date_of_event
      t.string :title_of_event
      t.string :location_of_event
      t.string :purpose_of_event
      t.integer :anticipated_no_of_attendees
      t.decimal :admission_charge_per_attendee
      t.integer :number_of_publicity_copies
      t.decimal :rental_equipment_services
      t.decimal :total_copy_rate
      t.decimal :copyright_fees
      t.decimal :total_eligible_Expenses
      t.decimal :admission_charge_revenue
      t.decimal :total_request_amount
      t.integer :version_id

      t.timestamps
    end
    add_index :local_event_expenses, :version_id
  end

  def self.down
    drop_table :local_event_expenses
  end
end

