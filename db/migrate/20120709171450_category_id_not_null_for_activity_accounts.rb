class CategoryIdNotNullForActivityAccounts < ActiveRecord::Migration

  class Category < ActiveRecord::Base
  end

  class ActivityAccount < ActiveRecord::Base
  end

  def up
    if ActivityAccount.where( category_id: nil ).any?
      say_with_time 'Creating default category and assigning activity accounts to it where they have no pre-existing association...' do
        category = Category.find_or_create_by_name  name: 'Default'
        ActivityAccount.where( category_id: nil ).update_all category_id: category.id
      end
    end
    change_column :activity_accounts, :category_id, :integer, null: false
    say 'Populating activity accounts for previously allocated requests'
    execute <<-SQL
      INSERT INTO activity_accounts ( fund_grant_id, category_id, created_at,
      updated_at ) SELECT DISTINCT fund_items.fund_grant_id,
      nodes.category_id, #{connection.quote Time.zone.now},
      #{connection.quote Time.zone.now} FROM fund_items INNER JOIN nodes
      ON fund_items.node_id = nodes.id
      WHERE fund_items.fund_grant_id IN (SELECT fund_grant_id FROM
      fund_requests WHERE state = 'allocated') AND fund_items.fund_grant_id
      NOT IN (SELECT fund_grant_id FROM activity_accounts WHERE
      activity_accounts.category_id = nodes.category_id)
    SQL
  end

  def down
    change_column :activity_accounts, :category_id, :integer, null: true
  end
end

