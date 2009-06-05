class CreateRequestStructures < ActiveRecord::Migration
  def self.up
    create_table :request_structures do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :request_structures
  end
end
