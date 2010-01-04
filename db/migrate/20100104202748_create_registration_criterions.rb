class CreateRegistrationCriterions < ActiveRecord::Migration
  def self.up
    create_table :registration_criterions do |t|
      t.boolean :must_register

      t.timestamps
    end
  end

  def self.down
    drop_table :registration_criterions
  end
end
