class AddAccessibilityConsideredToLocalEventExpenses < ActiveRecord::Migration
  def self.up
    add_column :local_event_expenses, :accessibility_considered, :boolean
  end

  def self.down
    remove_column :local_event_expenses, :accessibility_considered
  end
end

