class CreateRegistrationTerms < ActiveRecord::Migration
  def self.up
    create_table :registration_terms do |t|
      t.references :external, :null => false
      t.string :description
      t.boolean :current
      t.datetime :starts_at
      t.datetime :ends_at
    end
    add_index :registration_terms, :external_id, :unique => true
  end

  def self.down
    remove_index :registration_terms, :external_id
    drop_table :registration_terms
  end
end

