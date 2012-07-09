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
  end

  def down
    change_column :activity_accounts, :category_id, :integer, null: true
  end
end

