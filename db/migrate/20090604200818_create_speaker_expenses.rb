class CreateSpeakerExpenses < ActiveRecord::Migration
  def self.up
    create_table :speaker_expenses do |t|
      t.string :speaker_name, :null => false
      t.date :performance_date, :null => false
      t.decimal :mileage, { :null => false, :default => 0 }
      t.integer :number_of_speakers, { :null => false, :default => 1 }
      t.integer :nights_of_lodging, { :null => false, :default => 0 }
      t.decimal :engagement_fee, { :null => false, :default => 0 }
      t.decimal :car_rental, { :null => false, :default => 0 }
      t.integer :version_id, :null => false

      t.timestamps
    end
    add_index :speaker_expenses, :version_id
  end

  def self.down
    drop_table :speaker_expenses
  end
end

