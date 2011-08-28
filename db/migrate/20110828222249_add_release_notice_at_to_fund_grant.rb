class AddReleaseNoticeAtToFundGrant < ActiveRecord::Migration
  def change
    add_column :fund_grants, :release_notice_at, :datetime
  end
end
