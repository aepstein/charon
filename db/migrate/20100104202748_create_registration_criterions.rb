class CreateRegistrationCriterions < ActiveRecord::Migration
  def self.up
    create_table :registration_criterions do |t|
      t.boolean :must_register, :null => false
      t.integer :minimal_percentage, :null => false
      t.string :type_of_member, :null => false

      t.timestamps
    end
    add_index :registration_criterions, [:must_register, :minimal_percentage, :type_of_member],
      :unique => true, :name => 'registration_criterions_unique'
  end

  def self.down
    remove_index :registration_criterions, :registration_criterions_unique
    drop_table :registration_criterions
  end
end

