class AddEndDateToTravelEventExpenses < ActiveRecord::Migration
  class TravelEventExpense < ActiveRecord::Base; end

  def up
    add_column :travel_event_expenses, :end_date, :date
    rename_column :travel_event_expenses, :date, :start_date
    TravelEventExpense.reset_column_information
    TravelEventExpense.update_all("end_date = start_date")
    change_column :travel_event_expenses, :end_date, :date, :null => false
  end

  def down
    rename_column :travel_event_expenses, :start_date, :date
    remove_column :travel_event_expenses, :end_date
  end
end

