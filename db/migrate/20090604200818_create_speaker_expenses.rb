class CreateSpeakerExpenses < ActiveRecord::Migration
  def self.up
    create_table :speaker_expenses do |t|
      t.string :speaker_name
      t.date :performance_date
      t.decimal :mileage
      t.integer :number_of_speakers
      t.integer :nights_of_lodging
      t.decimal :engagement_fee
      t.decimal :car_rental
      t.decimal :tax_exempt_expenses
      t.integer :version_id

      t.timestamps
    end
    add_index :speaker_expenses, :version_id
  end

  def self.down
    drop_table :speaker_expenses
  end
end

