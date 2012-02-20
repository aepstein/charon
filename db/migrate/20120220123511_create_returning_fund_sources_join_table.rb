class CreateReturningFundSourcesJoinTable < ActiveRecord::Migration
  def up
    create_table :returning_fund_sources, id: false do |t|
      t.integer :fund_source_id, null: false
      t.integer :returning_fund_source_id, null: false
    end
    add_index :returning_fund_sources, [ :fund_source_id, :returning_fund_source_id ], name: 'unique_fund_sources', unique: true
  end

  def down
    remove_index :returning_fund_sources, name: 'unique_fund_sources'
    drop_table :returning_fund_sources
  end
end

