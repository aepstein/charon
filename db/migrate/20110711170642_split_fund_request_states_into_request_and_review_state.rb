class SplitFundRequestStatesIntoRequestAndReviewState < ActiveRecord::Migration
  def self.up
    remove_index :fund_requests, [ :fund_grant_id, :state ]
    rename_column :fund_requests, :state, :request_state
    add_column :fund_requests, :review_state, :string
    add_index :fund_requests, [ :fund_grant_id, :request_state, :review_state ]

    say 'Setting up new review_state field'
    execute <<-SQL
      UPDATE fund_requests SET review_state = 'unreviewed'
      WHERE request_state IN ( 'started', 'completed', 'submitted', 'accepted',
        'rejected', 'withdrawn' )
    SQL
    execute <<-SQL
      UPDATE fund_requests SET review_state = 'tentative'
      WHERE request_state IN ( 'reviewed' )
    SQL
    execute <<-SQL
      UPDATE fund_requests SET review_state = 'ready'
      WHERE request_state IN ( 'certified', 'released' )
    SQL
    change_column :fund_requests, :review_state, :string, :null => false

    say 'Setting request_state to appropriate values'
    execute <<-SQL
      UPDATE fund_requests SET request_state = 'tentative'
      WHERE request_state IN ( 'completed' )
    SQL
    execute <<-SQL
      UPDATE fund_requests SET request_state = 'finalized'
      WHERE request_state IN ( 'submitted' )
    SQL
    execute <<-SQL
      UPDATE fund_requests SET request_state = 'submitted'
      WHERE request_state IN ( 'accepted', 'reviewed', 'certified' )
    SQL
  end

  def self.down
    raise IrreversibleMigration
  end
end

