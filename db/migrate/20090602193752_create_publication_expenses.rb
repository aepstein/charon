class CreatePublicationExpenses < ActiveRecord::Migration
  def self.up
    create_table :publication_expenses do |t|
      t.integer :no_of_issues
      t.integer :no_of_copies_per_issue
      t.integer :total_copies
      t.decimal :purchase_price
      t.decimal :revenue
      t.decimal :cost_publication
      t.decimal :total_cost_publication
      t.integer :version_id

      t.timestamps
    end
  end

  def self.down
    drop_table :publication_expenses
  end
end

