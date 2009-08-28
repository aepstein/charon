class CreateSpeakerExpenses < ActiveRecord::Migration
  def self.up
    create_table :speaker_expenses do |t|
      t.string :title, :null => false
      t.integer :distance, { :null => false, :default => 0 }
      t.integer :number_of_travelers, { :null => false, :default => 1 }
      t.integer :nights_of_lodging, { :null => false, :default => 0 }
      t.decimal :engagement_fee, { :null => false, :default => 0 }
      t.boolean :dignitary, { :null => false, :default => false }
      t.integer :version_id, :null => false

      t.timestamps
    end
    add_index :speaker_expenses, :version_id
  end

  def self.down
    drop_table :speaker_expenses
  end
end

