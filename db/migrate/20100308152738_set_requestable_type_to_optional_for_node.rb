class SetRequestableTypeToOptionalForNode < ActiveRecord::Migration
  def self.up
    change_column :nodes, :requestable_type, :string, :null => true
  end

  def self.down
    raise IrreversibleMigration
  end
end

