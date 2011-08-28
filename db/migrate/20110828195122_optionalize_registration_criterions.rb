class OptionalizeRegistrationCriterions < ActiveRecord::Migration
  def up
    change_column :registration_criterions, :must_register, :boolean, :null => true
    change_column :registration_criterions, :minimal_percentage, :integer, :null => true
    change_column :registration_criterions, :type_of_member, :string, :null => true
  end

  def down
    change_column :registration_criterions, :must_register, :boolean, :null => false
    change_column :registration_criterions, :minimal_percentage, :integer, :null => false
    change_column :registration_criterions, :type_of_member, :string, :null => false
  end
end

