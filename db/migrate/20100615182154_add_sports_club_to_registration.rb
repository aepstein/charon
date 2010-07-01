class AddSportsClubToRegistration < ActiveRecord::Migration
  def self.up
    add_column :registrations, :sports_club, :boolean
  end

  def self.down
    remove_column :registrations, :sports_club
  end
end
