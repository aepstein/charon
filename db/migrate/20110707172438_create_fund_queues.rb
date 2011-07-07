class CreateFundQueues < ActiveRecord::Migration
  def self.up
    create_table :fund_queues do |t|
      t.references :fund_source, :null => false
      t.datetime :submit_at, :null => false
      t.datetime :release_at, :null => false

      t.timestamps
    end
    add_index :fund_queues, [ :fund_source_id, :submit_at ], :unique => true
  end

  def self.down
    remove_index :fund_queues, [ :fund_source_id, :submit_at ]
    drop_table :fund_queues
  end
end

