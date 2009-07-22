class CreateBases < ActiveRecord::Migration
  def self.up
    create_table :bases do |t|
      t.string :name, :null => false
      t.integer :structure_id, :null => false
      t.datetime :open_at, :null => false
      t.datetime :closed_at, :null => false
      t.integer :organization_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :bases
  end
end

