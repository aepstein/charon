class CreateFundRequestTypes < ActiveRecord::Migration
  def change
    create_table :fund_request_types do |t|
      t.string :name, :null => false
      t.boolean :allowed_for_first
      t.integer :amendable_quantity_limit
      t.integer :appendable_quantity_limit
      t.decimal :appendable_amount_limit

      t.timestamps
    end
    add_index :fund_request_types, :name, :unique => true
    create_table :fund_queues_fund_request_types, :id => false do |t|
      t.references :fund_queue, :null => false
      t.references :fund_request_type, :null => false
    end
    add_index :fund_queues_fund_request_types,
      [ :fund_queue_id, :fund_request_type_id ], :unique => true,
      :name => 'fund_queues_fund_request_types_unique'
  end
end

