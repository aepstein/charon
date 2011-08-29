class RemoveServicesCostFromLocalEventExpenses < ActiveRecord::Migration
  def up
    remove_column :local_event_expenses, :services_cost
  end

  def down
    add_column :local_event_expenses, :services_cost, :decimal
  end
end
