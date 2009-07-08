class CreateBases < ActiveRecord::Migration
  def self.up
    create_table :bases do |t|
      t.integer :structure_id
      t.string :kind, :null => false
      t.datetime :open_at
      t.datetime :closed_at

      t.timestamps
    end
  end

  def self.down
    drop_table :bases
  end
end

