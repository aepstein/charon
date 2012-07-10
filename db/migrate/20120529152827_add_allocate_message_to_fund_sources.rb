class AddAllocateMessageToFundSources < ActiveRecord::Migration
  def change
    add_column :fund_sources, :allocate_message, :text
  end
end

