class AddAdvertisedSubmitAtToFundQueues < ActiveRecord::Migration

  class FundQueue < ActiveRecord::Base
  end

  def up
    add_column :fund_queues, :advertised_submit_at, :datetime
    say 'Seeding advertised_submit_at with values from submit_at'
    FundQueue.update_all "advertised_submit_at = submit_at"
    change_column :fund_queues, :advertised_submit_at, :datetime, :null => false
  end

  def down
    remove_column :fund_queues, :advertised_submit_at
  end

end

