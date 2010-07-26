class CreateActivityReports < ActiveRecord::Migration
  def self.up
    create_table :activity_reports do |t|
      t.references :organization, :null => false
      t.integer :number_of_others, :null => false
      t.integer :number_of_undergrads, :null => false
      t.integer :number_of_grads, :null => false
      t.string :description, :null => false
      t.date :starts_on, :null => false
      t.date :ends_on, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :activity_reports
  end
end

