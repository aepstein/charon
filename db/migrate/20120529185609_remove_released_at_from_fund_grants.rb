class RemoveReleasedAtFromFundGrants < ActiveRecord::Migration
  def up
    add_column :fund_requests, :allocated_at, :datetime
    add_column :fund_requests, :allocated_notice_at, :datetime
    execute <<-SQL
      UPDATE fund_requests SET state = #{connection.quote 'allocated'},
      allocated_at = (SELECT released_at FROM fund_grants
        WHERE fund_grants.id = fund_requests.fund_grant_id),
      allocated_notice_at = (SELECT release_notice_at FROM fund_grants
        WHERE fund_grants.id = fund_requests.fund_grant_id)
      WHERE state = #{connection.quote 'released'} AND fund_grant_id IN
        (SELECT fund_grants.id FROM fund_grants WHERE released_at IS NOT NULL OR
          release_notice_at IS NOT NULL)
    SQL
    remove_column :fund_grants, :released_at
    remove_column :fund_grants, :release_notice_at
  end

  def down
    add_column :fund_grants, :release_notice_at, :datetime
    add_column :fund_grants, :released_at, :datetime
    execute <<-SQL
      UPDATE fund_grants SET released_at = (SELECT MAX(allocated_at)
        FROM fund_requests WHERE fund_grant_id = fund_grants.id ),
      release_notice_at = (SELECT MAX(allocated_notice_at)
        FROM fund_requests WHERE fund_grant_id = fund_grants.id ),
      state = #{connection.quote 'released'}
      WHERE state = #{connection.quote 'allocated'}
    SQL
    remove_column :fund_requests, :allocated_notice_at
    remove_column :fund_requests, :allocated_at
  end
end

