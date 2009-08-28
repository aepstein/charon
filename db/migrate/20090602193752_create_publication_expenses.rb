class CreatePublicationExpenses < ActiveRecord::Migration
  def self.up
    create_table :publication_expenses do |t|
      t.integer :no_of_issues, :null => false
      t.integer :no_of_copies_per_issue, :null => false
      t.integer :total_copies, { :null => false, :default => 0 }
      t.decimal :purchase_price, { :null => false, :default => 0 }
      t.decimal :revenue, { :null => false, :default => 0 }
      t.decimal :cost_publication, { :null => false, :default => 0 }
      t.decimal :total_cost_publication, { :null => false, :default => 0 }
      t.integer :version_id, :null => false

      t.timestamps
    end
    add_index :publication_expenses, :version_id
  end

  def self.down
    drop_table :publication_expenses
  end
end

