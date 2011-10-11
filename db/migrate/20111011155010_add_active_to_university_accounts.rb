class AddActiveToUniversityAccounts < ActiveRecord::Migration
  def change
    add_column :university_accounts, :active, :boolean
  end
end
