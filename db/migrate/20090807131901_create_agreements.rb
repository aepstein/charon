class CreateAgreements < ActiveRecord::Migration
  def self.up
    create_table :agreements do |t|
      t.string :name, :null => false
      t.text :content, :null => false

      t.timestamps
    end
    add_index :agreements, :name, :unique => true
    create_table :agreements_permissions, :id => false do |t|
      t.references :agreement, :null => false
      t.references :permission, :null => false
    end
    add_index :agreements_permissions, [ :agreement_id, :permission_id ], :unique => true
  end

  def self.down
    drop_table :agreements_permissions
    drop_table :agreements
  end
end

