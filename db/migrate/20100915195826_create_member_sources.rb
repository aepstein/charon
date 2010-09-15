class CreateMemberSources < ActiveRecord::Migration
  def self.up
    create_table :member_sources do |t|
      t.references :organization
      t.references :role
      t.references :external_committee
      t.integer :minimum_votes

      t.timestamps
    end
  end

  def self.down
    drop_table :member_sources
  end
end
