class SplitFundRequestStatesIntoRequestAndReviewState < ActiveRecord::Migration
  def self.up
    remove_index :fund_requests, [ :fund_grant_id, :state ]
    add_column :fund_requests, :review_state, :string
    add_index :fund_requests, [ :fund_grant_id, :state, :review_state ],
      :name => 'index_grant_states'

    say 'Setting up new review_state field'
    execute <<-SQL
      UPDATE fund_requests SET review_state = 'unreviewed'
      WHERE state IN ( 'started', 'completed', 'submitted', 'accepted',
        'rejected', 'withdrawn' )
    SQL
    execute <<-SQL
      UPDATE fund_requests SET review_state = 'tentative'
      WHERE state IN ( 'reviewed' )
    SQL
    execute <<-SQL
      UPDATE fund_requests SET review_state = 'ready'
      WHERE state IN ( 'certified', 'released' )
    SQL
    change_column :fund_requests, :review_state, :string, :null => false

    say 'Setting fund_request state to appropriate values'
    execute <<-SQL
      UPDATE fund_requests SET state = 'tentative'
      WHERE state IN ( 'completed' )
    SQL
    execute <<-SQL
      UPDATE fund_requests SET state = 'finalized'
      WHERE state IN ( 'submitted' )
    SQL
    execute <<-SQL
      UPDATE fund_requests SET state = 'submitted'
      WHERE state IN ( 'accepted', 'reviewed', 'certified' )
    SQL
  end

  def self.down
    raise IrreversibleMigration
  end
end

