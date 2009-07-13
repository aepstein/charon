class CreateTravelEventExpenses < ActiveRecord::Migration
  def self.up
    create_table :travel_event_expenses do |t|
      t.date :event_date
      t.string :event_title
      t.string :event_location
      t.string :event_purpose
      t.integer :members_per_group
      t.integer :number_of_groups
      t.decimal :mileage
      t.integer :nights_of_lodging
      t.decimal :per_person_fees
      t.decimal :per_group_fees
      t.decimal :total_eligible_expenses
      t.integer :version_id

      t.timestamps
    end
  end

  def self.down
    drop_table :travel_event_expenses
  end
end

