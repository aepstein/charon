class AddShortDescriptionToRegistrationTerms < ActiveRecord::Migration
  def change
    add_column :registration_terms, :short_description, :string
  end
end
