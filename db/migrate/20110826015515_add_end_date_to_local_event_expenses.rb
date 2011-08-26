class AddEndDateToLocalEventExpenses < ActiveRecord::Migration

  class LocalEventExpense < ActiveRecord::Base; end

  def up
    add_column :local_event_expenses, :end_date, :date
    rename_column :local_event_expenses, :date, :start_date
    LocalEventExpense.reset_column_information
    LocalEventExpense.update_all("end_date = start_date")
    change_column :local_event_expenses, :end_date, :date, :null => false
  end

  def down
    rename_column :local_event_expenses, :start_date, :date
    remove_column :local_event_expenses, :end_date
  end
end

