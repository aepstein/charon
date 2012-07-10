class AddAllocateMessageToFundQueues < ActiveRecord::Migration
  def change
    add_column :fund_queues, :allocate_message, :text

  end
end
