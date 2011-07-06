class CreateFundGrants < ActiveRecord::Migration
  def self.up
    create_table :fund_grants do |t|
      t.references :organization, :null => false
      t.references :fund_source, :null => false
      t.string :state, :null => false, :default => 'new'

      t.timestamps
    end
    add_index :fund_grants, [ :organization_id, :fund_source_id ], :unique => true
  end

  def self.down
    remove_index :fund_grants, [ :organization_id, :fund_source_id ]
    drop_table :fund_grants
  end
end

