class AddTotalToAdministrativeExpenses < ActiveRecord::Migration
  def self.up
    add_column :administrative_expenses, :total, :decimal
  end

  def self.down
    remove_column :administrative_expenses, :total
  end
end
