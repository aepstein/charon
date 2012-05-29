class AddReleaseMessageToFundQueues < ActiveRecord::Migration
  def change
    add_column :fund_queues, :release_message, :text

  end
end
