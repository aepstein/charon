class RemoveClubSportFromOrganizations < ActiveRecord::Migration
  def up
    remove_column :organizations, :club_sport
  end

  def down
    add_column :organizations, :club_sport, :boolean, null: false, default: false
  end
end

