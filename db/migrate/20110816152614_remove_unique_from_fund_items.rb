class RemoveUniqueFromFundItems < ActiveRecord::Migration
  def up
    remove_index :fund_items, [ :fund_grant_id, :position ]
  end

  def down
    add_index :fund_items, [ :fund_grant_id, :position ],
      :unique => true
  end
end

