class CreateRequestBases < ActiveRecord::Migration
  def self.up
    create_table :request_bases do |t|
      t.integer :request_structure_id
      t.datetime :open_at
      t.datetime :closed_at

      t.timestamps
    end
  end

  def self.down
    drop_table :request_bases
  end
end
