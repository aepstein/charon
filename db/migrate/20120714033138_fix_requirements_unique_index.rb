class FixRequirementsUniqueIndex < ActiveRecord::Migration
  def up
    remove_index :requirements, name: :requirements_unique
    add_index :requirements, [ :framework_id, :fulfillable_type, :fulfillable_id, :role_id ],
      unique: true, name: :requirements_unique
  end

  def down
    raise IrreversibleMigration
  end
end

