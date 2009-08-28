class CreatePublicationExpenses < ActiveRecord::Migration
  def self.up
    create_table :publication_expenses do |t|
      t.string :title, :null => false
      t.integer :number_of_issues, :null => false
      t.integer :copies_per_issue, :null => false
      t.decimal :price_per_copy, { :null => false, :default => 0 }
      t.decimal :cost_per_issue, { :null => false, :default => 0 }
      t.integer :version_id, :null => false

      t.timestamps
    end
    add_index :publication_expenses, :version_id
  end

  def self.down
    drop_table :publication_expenses
  end
end

