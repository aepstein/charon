class MakeAllowedForFirstNotNullForFundRequestTypes < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE fund_request_types SET allowed_for_first = #{connection.quote false} WHERE allowed_for_first IS NULL
    SQL
    change_column :fund_request_types, :allowed_for_first, :boolean, null: false, default: false
  end

  def down
    change_column :fund_request_types, :allowed_for_first, :boolean, null: true
  end
end

