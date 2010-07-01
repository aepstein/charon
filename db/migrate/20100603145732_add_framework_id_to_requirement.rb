class AddFrameworkIdToRequirement < ActiveRecord::Migration
  def self.up
    say_with_time "Purging existing requirements for forward compatibility..." do
      rows = connection.send(:delete_sql, "DELETE FROM requirements")
      say "#{rows} rows updated.", true
    end
    add_column :requirements, :framework_id, :integer, :null => false
    remove_index :requirements, :name => 'requirements_unique'
    add_index :requirements, [ :framework_id, :fulfillable_id, :fulfillable_type ],
      :unique => true, :name => 'requirements_unique'
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

